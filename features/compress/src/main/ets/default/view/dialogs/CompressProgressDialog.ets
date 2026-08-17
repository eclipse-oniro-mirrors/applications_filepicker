/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import {
  Constant,
  EventBus,
  ExternalStorageUtil,
  FileCompressBusiness,
  FilePickerUtil,
  FileUtil,
  ProgressInfo,
  ResourceUtil,
  StartModeOptions,
  UiUtil
} from '@ohos/common';
import { CompressDialog } from '../CompressDialogs';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { DialogTitle } from '@ohos/customDialog/src/main/ets/default/view/dialog/DialogComponent';
import { i18n, intl } from '@kit.LocalizationKit';

export class ProgressDialogOptions {
  public taskType: string = Constant.OPERATION_TYPE.COMPRESSION;
  public workerName: string = '';
  public onCancel = () => {};
}

const PROGRESS_INFO_KEY = 'CompressProgressInfoMap';
const TASK_TITLE_MAP = new Map([
  [Constant.OPERATION_TYPE.COMPRESSION, $r('app.string.compress_file')],
  [Constant.OPERATION_TYPE.DECOMPRESSION, $r('app.string.decompress_file')]
]);

@Component
export struct CompressProgressDialog {
  @StorageProp(CompressDialog.PROGRESS_DIALOG_KEY) @Watch('onProgressDialogChange')
  progressDialogOptions?: ProgressDialogOptions = undefined;
  private controller?: CustomDialogController;
  private closeDialogBind: () => void = () => this.closeDialog();

  aboutToAppear(): void {
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear(): void {
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
      this.controller = undefined;
    }
  }

  onProgressDialogChange() {
    if (!this.progressDialogOptions) {
      this.controller?.close();
      this.controller = undefined;
      return;
    }
    this.controller = new CustomDialogController({
      builder: this.builder,
      alignment: DialogAlignment.Center,
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      cancel: () => {
        this.progressDialogOptions?.onCancel();
        this.controller = undefined;
      },
      autoCancel: false
    });
    this.controller.open();
  }

  private getTitle(): Resource {
    if (this.progressDialogOptions) {
      return TASK_TITLE_MAP.get(this.progressDialogOptions!.taskType)!;
    }
    return $r('app.string.compress_file');
  }

  build() {
  }

  @Builder
  builder() {
    Column() {
      Column() {
        DialogTitle({ title: this.getTitle() });
        ProgressBar({
          taskType: this.progressDialogOptions?.taskType,
          workerName: this.progressDialogOptions?.workerName,
          onFinished: () => { CompressDialog.closeProgressDialog(); }
        })
        Text($r('app.string.background_speed_limit_prompt'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .width('100%')
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_secondary'))
      }.padding({ left: 24, right: 24, bottom: 8 })
      this.cancelButton();
    }
  }

  @Builder
  cancelButton() {
    Row() {
      Button($r('app.string.cancel'))
        .onClick(() => {
          FileCompressBusiness.fileCompressCancel(this.progressDialogOptions?.workerName ?? '');
          this.progressDialogOptions?.onCancel();
        })
        .type(ButtonType.Normal)
        .constraintSize({ minHeight: 40 })
        .width('100%')
        .borderRadius($r('sys.float.corner_radius_level10'))
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
    }.padding({ left: 16, right: 16, bottom: 16 })
  }
}

@Component
struct ProgressBar {
  taskType: string = '';
  workerName: string = '';
  onFinished: Function = () => {};
  private isBigMode: Boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x;
  @State rate: number = 0;
  @State taskDesc: string = '';
  @State targetFileUri: string = ''; // 压缩/解压输出的uri(u盘和云盘退出时使用)
  @StorageLink(PROGRESS_INFO_KEY) @Watch('updateRate') infoMap: Map<string, ProgressInfo[]> = new Map();
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private hasReceivedProgress: boolean = false;

  aboutToAppear() {
    this.updateRate();
  }

  private async updateRate() {
    const infoList = this.infoMap.get(this.taskType) ?? [];
    const index = infoList.findIndex((progressInfo: ProgressInfo) => progressInfo.workerName === this.workerName);
    if (index > -1) {
      this.hasReceivedProgress = true;
      await this.initTaskDesc(infoList[index].operateFileName);
      this.targetFileUri = FileUtil.getUriFromPath(infoList[index].outputFilePath);
      this.rate = infoList[index].progressBarInfo.progressRate;
    } else if (this.hasReceivedProgress) {
      this.hasReceivedProgress = false;
      this.onFinished();
    }
  }

  private async initTaskDesc(operateFileName: string) {
    if (this.taskType === Constant.OPERATION_TYPE.COMPRESSION) {
      if (operateFileName.startsWith('string:')) {
        this.taskDesc = ResourceUtil.getStringByOneParamResource($r('app.string.compressing_file'),
          operateFileName.replace('string:', ''));
      }
      if (operateFileName.startsWith('number:')) {
        this.taskDesc = await ResourceUtil.getStringByPluralParamResource($r('app.plural.compressing_file'),
          Number(operateFileName.replace('number:', '')));
      }
    } else {
      if (operateFileName.startsWith('string:')) {
        this.taskDesc = ResourceUtil.getStringByOneParamResource($r('app.string.decompressing_file'),
          operateFileName.replace('string:', ''));
      }
      if (operateFileName.startsWith('number:')) {
        this.taskDesc = await ResourceUtil.getStringByPluralParamResource($r('app.plural.decompressing_file'),
          Number(operateFileName.replace('number:', '')));
      }
    }
  }

  private getPercentage(): string {
    let percentage = new intl.NumberFormat(i18n.System.getSystemLanguage(), {style: 'percent'});
    return percentage.format(this.rate / 100);
  }

  build() {
    Column() {
      this.layout();
      this.progress();
    }
  }

  @Builder layout(){
    Flex({
      alignItems: this.isBigMode ? ItemAlign.Start : ItemAlign.Center,
      direction: this.isBigMode ? FlexDirection.Column : FlexDirection.Row
    }){
      Text(this.taskDesc)
        .textAlign(TextAlign.Start)
        .constraintSize({ minHeight: 19 })
        .wordBreak(WordBreak.BREAK_ALL)
        .maxLines(2) // 超长文本最多显示两行
        .width(this.isBigMode ? '100%' : 0)
        .flexGrow(this.isBigMode ? undefined : 1)
        .margin({ top: this.isBigMode ? 8 : 0 }) // 纵向布局时上边距留出8vp
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text(this.getPercentage())
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .width(this.isBigMode ? '100%' : 'auto')
        .margin({
          left: this.isBigMode ? 0 : 16, // 横向布局时左边留出16vp间距
          top: this.isBigMode ? 4 : 0, // 纵向布局时上边留出4vp间距
        })
        .textAlign(this.isBigMode ? TextAlign.Start : TextAlign.End)
    }
    .height('auto')
    .padding({ top: this.isBigMode ? 0 : 13 }) // 常规缩放比情况下内容区设置顶部边距为13vp
  }

  @Builder
  progress() {
    Column() {
      Progress({ value: 0, type: ProgressType.Linear })
        .value(Math.max(this.rate, 1))
        .style({ enableSmoothEffect: false })
        .color($r('sys.color.comp_background_emphasize'))
    }
    .height(24)
    .justifyContent(FlexAlign.Center)
  }
}