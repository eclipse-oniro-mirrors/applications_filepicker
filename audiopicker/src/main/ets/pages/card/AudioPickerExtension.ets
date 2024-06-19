/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2022. All rights reserved.
 */

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';

import { Logger } from '../../common/util/HiLogger'
import {  MusicApp } from '../../common/global/globalmodel/GlobalModel';
import { createOrGet, globalKeys } from '../../common/global/GlobalThisHelper'
import { AudioPickerView } from './AudioPickerView';

let storage = LocalStorage.getShared()
const app: MusicApp = createOrGet(MusicApp, globalKeys.app);
const logger: Logger = new Logger('AudioPickerExtension')

/**
 * [扩展Ability入口页面文件extension]
 *
 * @version [V1.0.0.0, 2024/4/9]
 * @since V1.0.0.0
 */
@Entry(storage)
@Component
struct AudioPickerExtension {
  @State hoverIndex: number = -1
  @State actionIsHover: boolean = false
  @State isShow: boolean = false
  private session: UIExtensionContentSession | undefined = storage.get<UIExtensionContentSession>('session');
  private want: Want | undefined = storage.get<Want>('want');
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    logger.info('aboutToAppear')
    app.abilityContext = this.context
    this.isShow = true
  }

  aboutToDisappear(): void {
    storage.clear()
  }

  /**
   * 半模态框标题
   */
  @Builder
  titleStyle() {
    Text($r('app.string.select_audio'))
      .fontSize(20)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontWeight(FontWeight.Bold)
  }

  @Builder
  //装饰器
  myBuilder() {
    Column() {
      AudioPickerView({
        isShow: $isShow,
        session: this.session,
        want: this.want
      });
    }
  }

  build() {
    Row() {
    }
    .width('100%')
    .height('100%')
    .bindSheet(
      this.isShow, //是否显示半模态页面
      this.myBuilder(), //builder：配置半模态页面内容
      {
        title: this.titleStyle,
        height: SheetSize.FIT_CONTENT,
        dragBar: false, //是否显示控制条，默认显示
        preferType: SheetType.CENTER,
        onAppear: () => {
          logger.info('BindSheet onAppear.') //半模态页面显示回调函数
        },
        onDisappear: () => {
          if (this.session !== undefined) {
            this.session.terminateSelf()
          }
          logger.info('BindSheet onDisappear.') //半模态页面回退回调函数
        }
      })
  }
}