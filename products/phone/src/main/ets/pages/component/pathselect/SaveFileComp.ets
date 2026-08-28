/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  AbilityCommonUtil,
  AppInfo,
  ArrayUtil,
  Constant,
  ERROR_CODE,
  EventBus,
  FileInfo,
  FileMimeTypeUtil,
  FilePickerUtil,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  PageUtil,
  RenameUtil,
  ResourceUtil,
  ResultCodePicker,
  StartModeOptions,
  StringUtil,
  TaskManager,
  toast,
  VirtualUri
} from '@ohos/common';
import { FileIconStackComp } from './FileIconStackComp';
import { WaitingDialog } from '@ohos/customDialog/src/main/ets/default/view/dialog/WaitingDialog';
import { SaveFilesResult, CheckFileDupWithFolderResult } from '@ohos/common/src/main/ets/gallery/SaveFilesResult';
import lazy { CheckFileNameDuplicateTask, SaveFileTask } from '../../../taskpool/task/SaveFileTask';
import { accessibility } from '@kit.AccessibilityKit';
import { bundleResourceManager } from '@kit.AbilityKit';
import { ConfirmTemplateDialog, SaveFileConflictDialog } from '@ohos/customDialog';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import App from '@system.app';

const TAG = 'SaveFileComp';

const MAX_SAVA_COUNT: number = 500;

@Component
export struct SaveFileComp {
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  inputController: TextInputController = new TextInputController();
  @Prop selectedFolderUri: string = '';
  @Prop @Watch('initOperationTitle') selectedFolderName: Resource | string = '';
  @State errorText?: Resource = undefined;
  @State tempFileInfoList: Array<FileInfo> = [];
  @State saveOneFileName: string = '';
  @State operationTitle?: Resource = undefined;
  isOnlySaveOneFile: boolean = false;
  resolvePathSelectEndBind: Function =
    (folderUri: string): Promise<void> => this.resolvePathSelectEnd(folderUri, this.startModeOptions);
  loadingDialog: CustomDialogController = new CustomDialogController({
    builder: WaitingDialog(),
    autoCancel: false
  })
  notSupportGalleryDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmTemplateDialog({
      title: $r('app.string.save_file'),
      content: $r('app.string.failed_save_to_gallery_root_path'),
      firstButtonText: $r('app.string.get_it'),
      firstButtonCallback: (): void => {
      }
    }),
    autoCancel: false
  })
  /**
   * 文件名是否已超最大长度
   */
  isExceedMaxLen: boolean = false;
  /**
   * 关标上次在的位置
   */
  lastCaretPosition: number = 0;

  aboutToAppear(): void {
    this.initSaveFileInfo();
    this.initOperationTitle();
    this.addEventListener();
  }

  aboutToDisappear(): void {
    this.removeEventListener();
    this.loadingDialog.close();
  }

  addEventListener(): void {
    EventBus.on(Constant.EVENTS.CLOSE_PATH_PICKER + this.startModeOptions.currentCreateTimeStamp,
      this.resolvePathSelectEndBind, true);
  }

  removeEventListener(): void {
    EventBus.off(Constant.EVENTS.CLOSE_PATH_PICKER + this.startModeOptions.currentCreateTimeStamp,
      this.resolvePathSelectEndBind);
  }

  async resolvePathSelectEnd(folderUri: string, startModeOptions: StartModeOptions): Promise<void> {
    if (StringUtil.isEmpty(folderUri)) {
      AbilityCommonUtil.terminatePathPicker([], AbilityCommonUtil.ResultCodePicker.CANCEL, this.startModeOptions);
      HiLog.warn(TAG, 'resolvePathSelectEnd, folderUri is empty');
      return;
    }
    // 图库根目录不支持存文件
    if (folderUri === VirtualUri.GALLERY) {
      HiLog.error(TAG, 'gallery root folder not support saving file');
      this.notSupportGalleryDialog.open();
      return;
    }
    const fileNameList = this.isOnlySaveOneFile ? [this.saveOneFileName] : startModeOptions.newFileNames;
    for (let i = 0; i < fileNameList.length; i++) {
      const checkResult: boolean = this.checkFileName(fileNameList[i]);
      if (!checkResult) {
        HiLog.error(TAG, 'resolvePathSelectEnd fileName is wrong.');
        return;
      }
    }
    if (fileNameList.length > MAX_SAVA_COUNT) {
      AbilityCommonUtil.terminatePathPicker([], AbilityCommonUtil.ResultCodePicker.CANCEL, this.startModeOptions);
      HiLog.error(TAG, 'resolvePathSelectEnd, fileNameList length is over the limit.');
      return;
    }

    const bundleName: string = this.getBundleName();
    let appInfo: AppInfo | undefined = this.getAppInfo();
    if (folderUri.startsWith(Constant.MediaLibrary_URI_HEAD) && appInfo) {
      HiLog.info(TAG, 'save gallery:' + fileNameList.length);
      return await this.SaveGalleryFiles(folderUri, fileNameList, appInfo);
    }
    this.loadingDialog.open();
    if (this.isOnlySaveOneFile) {
      let isDupWithFolder: boolean = false;
      let isExist: boolean = false;
      let uri: string = `${folderUri}/${encodeURIComponent(this.saveOneFileName)}`;
      HiLog.infoPrivate(TAG, 'save onefile:', uri);
      let checkFileNameDuplicateTask: CheckFileNameDuplicateTask =
        new CheckFileNameDuplicateTask(uri, (checkResult: CheckFileDupWithFolderResult) => {
          if (checkResult.err) {
            this.loadingDialog.close();
            toast($r('app.string.save_file_fail'));
            return;
          }
          isExist = checkResult.isExist;
          isDupWithFolder = checkResult.isDupWithFolder;
          if (!isExist || isDupWithFolder) {
            this.saveFiles(folderUri, fileNameList, bundleName, new AppInfo(), isDupWithFolder);
            return;
          }
          this.loadingDialog.close();
          let dial = new CustomDialogController({
            builder: SaveFileConflictDialog({
              content: $r('app.string.save_have_same_name'),
              confirm: () => {
                HiLog.info(TAG, 'User select confirm.');
                this.loadingDialog.open();
                this.saveFiles(folderUri, fileNameList, bundleName);
                dial.close();
              },
              cancel: () => {
                HiLog.info(TAG, "User select cancel.");
                dial.close();
              },
              cancelText: $r('app.string.cancel'),
              confirmText: $r('app.string.replace'),
            }),
            autoCancel: false,
            alignment: DialogAlignment.Center
          })
          dial.open();
          return;
        });
      TaskManager.getInstance().execute<boolean[]>(checkFileNameDuplicateTask);
      return;
    }

    this.saveFiles(folderUri, fileNameList, bundleName);
  }

  checkFileName(fileName: string): boolean {
    if (StringUtil.isEmpty(fileName.trim())) {
      HiLog.error(TAG, 'There is no content.');
      this.errorMsg($r('app.string.emptyName'));
      this.accessibilityTips();
      return false;
    }
    if (StringUtil.strSizeUTF8(fileName) > Constant.MAX_FILENAME_LENGTH) {
      HiLog.error(TAG, 'Maximum length reached.');
      this.errorMsg($r('app.string.max_input_length'));
      this.accessibilityTips();
      return false;
    }
    if (RenameUtil.checkOnlyExtension(fileName)) {
      HiLog.error(TAG, 'Enter a complete file name.');
      this.errorMsg($r('app.string.completeName'));
      this.accessibilityTips();
      return false;
    }
    if (RenameUtil.checkSpecialChar(fileName)) {
      HiLog.error(TAG, 'Has unsupported char.');
      this.errorMsg($r('app.string.not_support_characters_new', Constant.FILENAME_REGEXP_CONTENT));
      this.accessibilityTips();
      return false;
    }
    return true;
  }

  saveFileTaskCallback(result: SaveFilesResult): void {
    HiLog.info(TAG, 'create files end');
    this.loadingDialog.close();
    if (!ArrayUtil.isEmpty(result.dataArr)) {
      HiLog.info(TAG, 'create files success, terminate path picker');
      AbilityCommonUtil.terminatePathPicker(result.dataArr, ResultCodePicker.SUCCESS, this.startModeOptions);
      return;
    }
    HiLog.info(TAG, 'create files end, err occured');
    const errorCode = result.err.code;
    // 保存一个文件失败且错误码为重名时不关闭路径选择器
    if (this.isOnlySaveOneFile && (errorCode === ERROR_CODE.FILE_ACCESS.FILE_EXISTS)) {
      this.errorText = $r('app.string.save_file_has_same_file');
      this.accessibilityTips();
      return;
    }
    AbilityCommonUtil.terminatePathPicker([], errorCode, this.startModeOptions);
    toast($r('app.string.save_file_fail'));
  }

  initSaveFileInfo() {
    const fileNameList = this.startModeOptions.newFileNames;
    for (let fileName of fileNameList) {
      let fileData = new FileInfo();
      fileData.fileName = fileName;
      fileData.mimeTypeObj = FileMimeTypeUtil.getMimeType(fileName, false);
      this.tempFileInfoList.push(fileData);
    }
    let fileName: string = '';
    if (this.tempFileInfoList && this.tempFileInfoList.length > 0) {
      fileName = this.tempFileInfoList?.[0].fileName;
    }
    this.isOnlySaveOneFile = this.tempFileInfoList.length === 1;
    if (this.isOnlySaveOneFile && fileName) {
      const fileSuffix = AbilityCommonUtil.getFileSuffixChoices(this.startModeOptions);
      if (StringUtil.isEmpty(fileSuffix)) {
        this.saveOneFileName = fileName;
      } else {
        const suffixes = FilePickerUtil.getFileSuffix(fileName);
        if (suffixes.length > 0) {
          const prefixes = FilePickerUtil.getFilePrefix(fileName);
          this.saveOneFileName = prefixes + fileSuffix;
        } else {
          this.saveOneFileName = fileName + fileSuffix;
        }
      }
    }
  }

  initOperationTitle(): void {
    if (this.isOnlySaveOneFile) {
      this.operationTitle = $r('app.string.to_save', this.selectedFolderName);
    } else {
      this.operationTitle = $r('app.plural.to_save_plural', this.tempFileInfoList.length, this.tempFileInfoList.length,
        this.selectedFolderName);
    }
  }

  onTextInputChange(newValue: string): void {
    this.errorText = undefined;
    let newFileNameByteLen: number = StringUtil.strSizeUTF8(newValue);
    if (this.isExceedMaxLen) {
      this.errorText = $r('app.string.max_input_length');
      this.accessibilityTips();
      // 文件名超长截取后需重新设置光标的位置
      this.inputController.caretPosition(this.lastCaretPosition);
    }
    this.saveOneFileName = newValue;
    if (newFileNameByteLen > Constant.MAX_FILENAME_LENGTH) {
      const caretPosition = this.inputController.getCaretOffset().index;
      const afterCaretStr = this.saveOneFileName.substring(caretPosition);
      this.saveOneFileName = FileUtil.getMaxLengthFileName(newValue, caretPosition, Constant.MAX_FILENAME_LENGTH);
      // 超长截取后会触发输入框刷新所以需要记录光标应该所处的位置
      if (StringUtil.isEmpty(afterCaretStr)) {
        this.lastCaretPosition = this.saveOneFileName.length;
      } else {
        this.lastCaretPosition = this.saveOneFileName.lastIndexOf(afterCaretStr);
      }
      this.isExceedMaxLen = true;
      this.errorText = $r('app.string.max_input_length');
      this.accessibilityTips();
    } else {
      this.isExceedMaxLen = false;
    }
  }

  build() {
    Row() {
      if (this.tempFileInfoList.length !== 1) {
        FileIconStackComp({
          selectFilesList: this.tempFileInfoList,
          isSaveFile: true
        })
      }
      Column() {
        Text(this.operationTitle)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.isOnlySaveOneFile) {
          this.buildFileNameInput()
        }
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }.width('100%')
    .padding({
      right: $r('app.float.common_padding24'),
      left: $r('app.float.common_padding24'),
      bottom: $r('app.float.common_padding15')
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildFileNameInput() {
    Column() {
      TextInput({ text: this.saveOneFileName, controller: this.inputController })
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .backgroundColor($r('app.color.text_input_bg_color'))
        .draggable(false)
        .enableKeyboardOnFocus(false)
        .onChange((newValue: string) => {
          this.onTextInputChange(newValue)
        })
        .onFocus(() => {
          this.inputController.setTextSelection(0, this.getLengthWithoutSuffix(this.saveOneFileName));
        })
        .margin({
          left: $r('app.float.common_margin_minus14'),
          right: $r('app.float.common_margin_minus14')
        })
      Divider().vertical(false).strokeWidth(1).color($r('sys.color.ohos_id_color_list_separator'))
        .margin({
          bottom: $r('app.float.common_margin2')
        })
      Text(this.errorText)
        .padding({
          top: $r('app.float.common_padding5')
        })
        .fontSize($r('app.float.common_font_size14'))
        .fontColor($r('sys.color.ohos_id_color_warning'))
    }.width('100%')
    .margin({
      top: $r('app.float.common_size10')
    })
    .alignItems(HorizontalAlign.Start)
  }

  private async SaveGalleryFiles(folderUri: string, fileNameList: string[], appInfo: AppInfo) {
    if ((folderUri === VirtualUri.GALLERY || folderUri?.startsWith(VirtualUri.GALLERY_URI)) &&
      !await PhotoAccessUtil.initPhotoSupportedFormats(GlobalHolder.getInstance().getAppContext())) {
      toast($r('app.string.disabled'));
      return;
    }
    const isScreenShotAlbum = folderUri ===
      await PhotoAccessUtil.getAlbumUriByBundleName(getContext(), Constant.SCREEN_SHOT_BUNDLE_NAME)
    const isScreenRecorderAlbum = folderUri ===
      await PhotoAccessUtil.getAlbumUriByBundleName(getContext(), Constant.SCREEN_RECORDER_BUNDLE_NAME)

    let galleryNameList: Array<string> = [];
    let result: boolean[][] = [];
    for (let fileName of fileNameList) {
      let support: boolean[] =
        await PhotoAccessUtil.getPhotoSupportedFormats(this.startModeOptions.context, fileName);
      result.push(support);
    }

    if (isScreenShotAlbum) {
      galleryNameList = fileNameList.filter((_, index) => {
        return result[index][0];
      })
    } else if (isScreenRecorderAlbum) {
      galleryNameList = fileNameList.filter((_, index) => {
        return result[index][1];
      })
    } else {
      galleryNameList = fileNameList.filter((_, index) => {
        return result[index][0] || result[index][1];
      })
    }
    HiLog.error(TAG,
      `isScreenShot: ${isScreenShotAlbum}, isScreenRecorder: ${isScreenRecorderAlbum}, filterlength: ${galleryNameList.length},
        originlength: ${fileNameList.length}`);
    if (galleryNameList.length === fileNameList.length && galleryNameList.length > 0) {
      HiLog.info(TAG, 'can save file');
      this.loadingDialog.open();
      this.saveFiles(folderUri, galleryNameList, appInfo.bundleName, appInfo);
    } else {
      let dialogContent: Resource | undefined = undefined;
      if (isScreenShotAlbum || isScreenRecorderAlbum) {
        if (galleryNameList.length === 0) {
          dialogContent =
            isScreenShotAlbum ? $r('app.string.save_image_to_gallery_album_for_picker', this.selectedFolderName) :
            $r('app.string.save_video_to_gallery_album_for_picker', this.selectedFolderName);
        } else {
          dialogContent = isScreenShotAlbum ? $r('app.string.save_image_to_gallery_album', this.selectedFolderName) :
          $r('app.string.save_video_to_gallery_album', this.selectedFolderName);
        }
      } else {
        dialogContent =
          $r(galleryNameList.length === 0 ? 'app.string.save_other_type_files_to_gallery_path_for_picker' :
            'app.string.save_other_type_files_to_gallery_path');
      }
      let dialog: CustomDialogController = new CustomDialogController({
        builder: ConfirmTemplateDialog({
          title: $r('app.string.save_file'),
          content: dialogContent,
          firstButtonText: galleryNameList.length === 0 ? $r('app.string.get_it') : $r('app.string.cancel'),
          firstButtonCallback: (): void => {
            HiLog.info(TAG, 'close dialog');
            dialog.close()
          },
          secondButtonCallback: galleryNameList.length === 0 ? undefined : (): void => {
            this.loadingDialog.open();
            this.saveFiles(folderUri, galleryNameList, appInfo.bundleName, appInfo)
          }
        }),
        autoCancel: false
      })
      dialog.open();
    }
  }

  private saveFiles(folderUri: string, fileNameList: string[], bundleName: string, appInfo: AppInfo = new AppInfo(),
    isDupWithFolder: boolean = false) {
    const context = getContext();
    const saveFileTask: SaveFileTask =
      new SaveFileTask(context, folderUri, fileNameList, bundleName, (result: SaveFilesResult) => {
        this.saveFileTaskCallback(result);
      }, appInfo, isDupWithFolder);
    TaskManager.getInstance().execute<SaveFilesResult>(saveFileTask);
  }

  // 获取应用包名
  private getBundleName(): string {
    const storage = LocalStorage.getShared();
    // 目前通过documentPicker、filePicker都可进行保存文件，兼容两种方式
    if (AppStorage.has('bundleName')) {
      return AppStorage.get('bundleName')!;
    } else if (storage.has('bundleName')) {
      return storage.get('bundleName')!;
    } else {
      return this.startModeOptions.callerBundleName;
    }
  }

  private getAppResourceInfo(bundleName: string): string {
    HiLog.info(TAG, `getAppResourceInfo start`);
    const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
    let appName: string = '';
    try {
      const resourceInfo = bundleResourceManager.getBundleResourceInfo(bundleName, bundleFlags);
      HiLog.info(TAG, `getBundleResourceInfo successfully. Data label: ${resourceInfo.label}`);
      appName = resourceInfo.label;
    } catch (err) {
      HiLog.error(TAG, `getBundleResourceInfo failed: ${err?.code}, message: ${err?.message}`);
    }
    return appName;
  }

  // 获取应用包名
  private getAppInfo(): AppInfo | undefined {
    HiLog.info(TAG, 'getAppInfo start ')
    let appInfo = new AppInfo();
    const want: Want = GlobalHolder.getInstance().getObject<Want>(GlobalKey.ABILITY_WANT)
    if (!want) {
      HiLog.error(TAG, 'getAppInfo error due to no want')
      return undefined
    }
    appInfo.bundleName = want.parameters?.['ohos.aafwk.param.callerBundleName'] as string ?? '';
    appInfo.tokenId = want.parameters ? want.parameters[AbilityCommonUtil.CALLER_TOKEN] as number ?? 0 : 0;
    appInfo.appId = want.parameters?.['ohos.aafwk.param.callerAppId'] as string ?? '';
    const storage = LocalStorage.getShared();
    if (storage) {
      appInfo.appName = storage.get('appName')!;
    }

    if (!appInfo.bundleName || !appInfo.tokenId || !appInfo.appId) {
      HiLog.error(TAG, 'getAppInfo can not get want param');
      return undefined
    }

    if (!appInfo.appName) {
      appInfo.appName = this.getAppResourceInfo(appInfo.bundleName,)
    }

    if (!appInfo.appName) {
      HiLog.error(TAG, 'getAppInfo can not get appName')
      return undefined
    }
    return appInfo;
  }

  private errorMsg(errorText: Resource) {
    if (this.isOnlySaveOneFile) {
      this.errorText = errorText;
    } else {
      toast(errorText);
    }
  }

  private getLengthWithoutSuffix(fileName: string): number {
    const indexOfDot = fileName.lastIndexOf('.');
    if (indexOfDot === -1) {
      return fileName.length;
    }
    const suffix = fileName.substring(indexOfDot);

    const index = fileName.lastIndexOf('.');
    return index === -1 ? fileName.length : index;
  }

  private accessibilityTips() {
    let announceEventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringByResource(this.errorText),
    });
    accessibility.sendAccessibilityEvent(announceEventInfo).then();
  }
}