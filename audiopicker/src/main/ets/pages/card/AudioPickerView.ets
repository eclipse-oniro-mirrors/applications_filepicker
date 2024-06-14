/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession'
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { ability, Context, Want } from '@kit.AbilityKit';

import { Logger } from '../../common/util/HiLogger'
import { createOrGet, globalKeys } from '../../common/global/GlobalThisHelper'
import { DeviceInfo, DeviceTypes } from '../../common/global/globalmodel/GlobalModel'
import { LocalAudioFile } from '../../localresource/localaudio/LocalAudioFile'
import { LocalResourceManager } from '../../localresource/LocalResourceManager';
import { AudioPickerViewData } from '../model/AudioPickerViewData';
import { AudioPickerViewModel } from '../viewmodel/AudioPickerViewModel';
import { AudioPickerPreference } from '../../audiopreference/AudioPickerPreference';
import { Constants } from '../../constant/Constants';

const logger: Logger = new Logger('AudioPickerView')

@Component
export struct AudioPickerView {
  @Link isShow: boolean;
  @State audioPickerData: AudioPickerViewData = new AudioPickerViewData()
  @State audioPickerViewModel: AudioPickerViewModel = new AudioPickerViewModel()
  @State localResourceManager: LocalResourceManager = new LocalResourceManager()
  // 选中列表信息
  @State isSelectedAudioPickerList: Array<LocalAudioFile> = []
  @State isSafetyTip: boolean = false
  @State audioPickerPreference: AudioPickerPreference =
    createOrGet(AudioPickerPreference, globalKeys.audioPickerPreference)
  // 是否展示加载更多
  @State showLoadMore: boolean = false
  @State requestCounts: number = 0
  @State isSelect: boolean = false
  // load more 提前的条目数量
  private loadMoreAdvance: number = 3
  private pageNo: number = 0;
  // 设备信息
  private globalDeviceInfo: DeviceInfo = createOrGet(DeviceInfo, globalKeys.deviceInfo)
  session: UIExtensionContentSession | undefined
  want: Want | undefined
  scroller: Scroller = new Scroller()
  context: Context = getContext(this)
  // 弹窗知道了按钮回调
  dialogKnow: () => void = () => {
    // 保存安全提示状态
    this.audioPickerPreference.saveSafetyTipStatus(true)
    logger.info('isSafetyTip ' + this.isSafetyTip)
    this.dialogController.close()
  }
  buildCustomDialog: () => void = () => {
    this.safetyTipDialogBuilder()
  }
  dialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: this.buildCustomDialog,
      buttons: [{
        value: $r('app.string.got_it'),
        fontColor: $r('sys.color.ohos_id_text_color_active'),
        action: this.dialogKnow
      }]
    }),
    alignment: DialogAlignment.Center
  })

  @Builder
  safetyTipDialogBuilder() {
    Column() {
      Stack() {
        Image($r('app.media.ic_public_privacy_big'))
          .height(28)
          .fillColor($r('sys.color.ohos_id_color_component_activated'))
        Image($r('app.media.img'))
          .width(24)
          .height(24)
          .zIndex(99)
          .borderRadius(5)
          .position({
            x: 24,
            y: 24
          })
      }
      .width(48)
      .height(48)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius($r('sys.float.corner_radius_level6'))
      .border({
        width: '1px',
        color: $r('sys.color.ohos_id_color_button_normal')
      })

      Text($r('app.string.secure_access_to_audio_library'))
        .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 280 : 352)
        .height(56)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(27)
        .textAlign(TextAlign.Center)

      Text($r('app.string.your_audio_will_be_displayed_here'))
        .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 280 : 352)
        .height(38)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(19)
        .textAlign(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? TextAlign.Start : TextAlign.Center)
    }
    .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? '100%' : 400)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  async aboutToAppear() {
    this.audioPickerData = this.audioPickerViewModel.getDataSource()
    logger.info('this.audioPickerData.getDataList(): ' + this.audioPickerData.getDataList())
    this.isSafetyTip = await this.audioPickerPreference.getSafetyTipStatus()
    this.audioPickerViewModel.queryAudioPickerList(this.pageNo, this.context)
    if (!this.isSafetyTip) {
      this.dialogController.open()
    }
  }

  routerBack: () => void = () => {
    if (this.session !== undefined) {
      this.session?.sendData({ 'isShowUIExtension': false })
      this.session?.terminateSelf()
    }
  }

  onBackPress() {
    this.routerBack()
  }

  /**
   * 是否是列表最后一个音频
   */
  isLast(index: number): boolean {
    this.requestCounts = Constants.PICKER_PAGE_SIZE * (this.pageNo + 1)
    let musicTotal: number = 0
    if (this.audioPickerData.totalCount() < this.requestCounts) {
      musicTotal = this.audioPickerViewModel.getAudioTotal()
    }
    if (musicTotal) {
      return index >= musicTotal - 1
    } else {
      return false
    }
  }

  /**
   * 返回赋予临时权限的uri列表回调
   */
  async settingTerminateSelfWithResult() {
    let uriArr = await this.localResourceManager.terminateSelfWithResult(this.isSelectedAudioPickerList)
    logger.info('uriArr length: ' + uriArr.length)
    if (this.session) {
      let abilityResult: ability.AbilityResult = {
        resultCode: (uriArr === undefined) ? -1 : 0,
        want: {
          parameters: {
            'ability.params.stream': uriArr,
            'uriArr': uriArr
          }
        }
      }
      this.session?.terminateSelfWithResult(abilityResult, (err) => {
        logger.error('terminateSelfWithResult is called: ' + err)
      })
    } else {
      logger.error(`oncancel session: ${this.session}`)
    }
    this.routerBack()
  }

  build() {
    if (this.audioPickerViewModel.audioTotal > 0) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Scroll(this.scroller) {
          Grid() {
            LazyForEach(this.audioPickerData, async (item: LocalAudioFile, index: number) => {
              GridItem() {
                Column() {
                  Row() {
                    Image(item.getThumbnail)
                      .width(48)
                      .height(48)
                      .margin({ right: 16 })
                      .borderRadius(8)
                      .draggable(false)
                      .id('audiopicker_thumbnail')

                    Column() {
                      Text(item.name)
                        .fontSize(16)
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontWeight(FontWeight.Medium)
                        .lineHeight(21)
                        .width('100%')
                        .height(21)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ bottom: 2 })
                        .id('audiopicker_name')

                      Text() {
                        if (item.artist && item.album) {
                          Span(item.artist)
                          Span('-')
                          Span(item.album)
                        } else if (item.artist || item.album) {
                          Span(item.artist || item.album)
                        } else {
                          Span('')
                        }
                      }
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                      .lineHeight(16)
                      .maxLines(1)
                      .width('100%')
                      .height(16)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .textAlign(TextAlign.Start)
                      .id('audiopicker_artist_album')
                    }
                    .width('calc(100% - 128vp)')
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                    .margin({ right: 40 })

                    Column() {
                      Checkbox()
                        .selectedColor($r('sys.color.ohos_id_color_component_activated'))
                        .shape(CheckBoxShape.CIRCLE)
                        .onChange((value) => {
                          if (value) {
                            this.isSelectedAudioPickerList.push(item)
                          } else {
                            this.isSelectedAudioPickerList = this.isSelectedAudioPickerList.filter(val => val != item)
                          }
                          let keyPickNum = this.want?.parameters?.key_pick_num
                          if (keyPickNum) {
                            if (this.isSelectedAudioPickerList.length < keyPickNum) {
                              this.isSelect = true
                            } else {
                              this.isSelect = false
                            }
                          }
                        })
                        .unselectedColor($r('sys.color.ohos_id_color_switch_outline_off'))
                        .width(20)
                        .height(20)
                    }
                    .width(24)
                    .height(24)
                  }
                  .width('100%')
                  .height(72)
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.SpaceBetween)

                  if (!this.isLast(index)) {
                    Divider()
                      .strokeWidth('1px')
                      .margin({ left: 64 })
                      .backgroundColor($r('sys.color.ohos_id_color_list_separator'))
                  }
                }
                .padding({ left: 16, right: 16 })
              }
            }, (item: LocalAudioFile) => {
              return item.uri
            })
          }
          .onScrollIndex((start, end) => {
            // 判断是否还有更多数据
            if (this.audioPickerData.totalCount() < this.requestCounts) {
              logger.warn(`audioPickerData less than ,size: ${this.audioPickerData.totalCount()}`)
              this.audioPickerData.hasMoreData = false
              return
            } else {
              this.audioPickerData.hasMoreData = true
            }
            // 判断首页数据是否满足一页
            if (this.audioPickerData) {
              if (this.audioPickerData.totalCount() < Constants.PICKER_PAGE_SIZE &&
                this.pageNo === Constants.PAGE_COUNT) {
                logger.warn('audioPickerData less than 100,size: ' + this.audioPickerData.totalCount())
                return
              }
            }
            // 判断是否是在加载中
            if (this.audioPickerData.isLoadMore || !this.audioPickerData.hasMoreData) {
              logger.warn('audioPickerData is showing more view : ' + this.showLoadMore + ' no more data: ' + this.audioPickerData.hasMoreData)
              return
            }
            // 查询下一页数据
            let lastIndex: number = this.audioPickerData.totalCount() - 1
            if (end >= lastIndex - this.loadMoreAdvance) {
              this.audioPickerData.hasMoreData = true
              this.audioPickerViewModel.loadMore(this.pageNo, this.context).then((res) => {
                if (res) {
                  // 加载成功后，页面+1
                  this.pageNo++
                  logger.info(`get success pageNo:${this.pageNo}`)
                }
              })
            }
          })
        }
        .scrollBar(BarState.Off)
        // 手机端列表高度要 - 标题 - 已选完成栏 - 提示语栏目 - 底部避让，其他设备不涉及底部避让
        .margin({ bottom: this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 108 : 96 })

        Column() {
          Row() {
            Text() {
              Span($r('app.string.is_elected'))
              Span(`（${this.isSelectedAudioPickerList.length}）`)
            }
            .fontSize(16)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .height(22)
            .id('audiopicker_selected')

            Button($r('app.string.complete'), { type: ButtonType.Capsule, stateEffect: false })
              .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
              .backgroundColor($r('sys.color.ohos_id_color_component_activated'))
              .opacity(this.isSelectedAudioPickerList.length ? 1 : 0.4)
              .width(72)
              .height(28)
              .onClick(() => {
                if (this.isSelectedAudioPickerList.length > 0) {
                  this.settingTerminateSelfWithResult()
                  this.isShow = false
                } else {
                  this.isShow = true
                }
              })
              .id('audiopicker_button')
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Image($r('app.media.ic_public_privacy'))
              .width(14)
              .height(14)
            Text($r('app.string.only_selected_items_can_be_accessed'))
              .fontSize(12)
              .fontColor($r('sys.color.ohos_id_color_tertiary'))
              .width(96)
              .height(16)
          }
          .width(114)
          .height(28)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .backgroundColor($r('sys.color.ohos_id_blur_style_component_thick_color'))
        .height(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 108 : 96)
        .padding(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? { bottom: 28 } : { bottom: 0 })
      }
      .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? '100%' : 480)
      .height(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 684 : 560)
    } else {
      Column() {
        Image($r('app.media.emptypage'))
          .width(96)
          .height(96)
          .margin({ bottom: 8 })

        Text($r('app.string.no_matching_content'))
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .lineHeight(19)
      }
      .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? '100%' : 480)
      .height(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 411 : 560)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}