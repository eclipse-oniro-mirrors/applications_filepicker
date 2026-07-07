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
import { updateFolderNameAndFileNameResource } from '../../../base/utils/Common';
import {
  ArrayUtil,
  Constant,
  DiskInfo,
  EventBus,
  TaskStatus,
  GlobalHolder,
  GlobalKey,
  HiLog,
  ObjectUtil,
  PreferenceConst,
  StringUtil,
  TaskManager,
  TaskPoolName,
  AbilityCommonUtil,
  FileInfo,
  FileUtil,
  PageUtil,
  StorageDeviceManager,
  ToolBarStyle,
  StartModeOptions,
  FilePickerUtil,
  CommonPreferenceUtil,
  getResourceString,
  renderSize,
  toast,
  CompId,
  ResourceUtil,
  MyPhoneConstant,
  VirtualUri,
  TraceUtils,
  UiUtil,
  AccessibilityManager,
  FolderData,
  DFX,
  EnumTransferUtil,
  UEUtil,
  RootInfo,
  DeviceConfig,
  AccessibilityStorageKey,
  ThrottlingUtil
} from '@ohos/common';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { FileMkdirDialog } from '@ohos/customDialog/indexPhoneOnly';
import { PathSelectTreeItem } from './PathSelectTreeItem';
import { PathPickerFolderDataSource } from '../../../databases/model/pathselector/PathPickerFolderDataSource';
import PathPickerUtil from '../../../base/utils/PathPickerUtil';
import { QuerySubFolderTask } from '../../../taskpool/task/QuerySubFolderTask';
import { SaveFileComp } from './SaveFileComp';
import { FileIconStackComp } from './FileIconStackComp';
import { ConfirmTemplateDialog } from '@ohos/customDialog';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { componentUtils, LengthMetrics } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

const TAG: string = 'SelectTree';
const AccessibilityTAG: string = 'ThrottlingAccessibility';
const PROGRESS_FOCUS_DELAY: number = 500;
const PATH_SELECT_TREE_HEADER_ID: string = 'PathSelectTreeHeader';
const PATH_SELECT_TREE_SCROLL_ID: string = 'PathSelectTreeScroll';

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_hover'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}

@Component
export struct PathSelectTree {
  /**
   * true 不展示，false 展示
   */
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @State listLength: number = 0;
  private rootFolderList: FolderData[] = [];
  @State selectUri: string =
    GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI) || ''; // 路径选择器选中的文件夹的uri
  @State @Watch('onSelectFolderChange') selectName: Resource | string = DeviceConfig.getInstance().config.myDevice;
  private selectFolderLevel: number = 0; // 路径选择器选中的文件夹的深度
  private selectFilesMaxLevel: number = 0; // 待复制/移动的文件列表的相对最大深度
  private selectFileUris: string[] = []; // 待复制/移动的文件夹Uri列表
  @Prop selectFilesList: FileInfo[] = []; // 待复制/移动的文件列表
  @State allFileSize: number = 0;
  @State hasFolder: boolean = false;
  @Prop operationType: string = '';
  private subFolderNameList: string[] = [];
  @State operationTitle?: Resource | string = undefined;
  @Prop isOutsideFolded: boolean = false;

  private pageName: DFX.PageName = DFX.PageName.UNKNOWN;
  private fileMkdirDialog: CustomDialogController = new CustomDialogController({
    builder: FileMkdirDialog({
      folderNameList: this.subFolderNameList,
      parentFolderUri: this.selectUri,
      confirm: (folderName: string, uri: string): void => this.createFolderSuccess(folderName, uri)
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
  /*
   * 判断picker的Header是否可以滚动
   */
  @State isHeaderScrollable: boolean = false;

  @State isTopImageLoaded: boolean = true;
  @State isBottomImageLoaded: boolean = true;
  private scroller: Scroller = new Scroller();
  private folderListShowStartIndex: number = 0;
  private folderListShowEndIndex: number = 0;
  @State pathPickerFolderDataSource: PathPickerFolderDataSource = new PathPickerFolderDataSource();
  private sdUsbChangeBind: Function = () => this.sdUsbChange();
  private newFolderUri: string = '';
  @State lastFolderUri: string = '';
  private showHiddenItem: boolean = false;

  // 每个picker实例选中最后uri需要进行存储
  private lastSelectFolderUri: string = '';

  async sdUsbChange(): Promise<void> {
    const diskInfoList: DiskInfo[] = await StorageDeviceManager.getInstance().getStorageDeviceList();
    HiLog.info(TAG,
      `sdUsbChange, diskInfoListSize: ${diskInfoList.length}, pathListSourceSize: ${this.pathPickerFolderDataSource.totalCount()}`)
    if (ArrayUtil.isEmpty(diskInfoList)) {
      return;
    }
    let needDeleteRootList: string[] = [];
    for (let rootFolder of this.rootFolderList) {
      let index = diskInfoList.findIndex(item => item.uri === rootFolder.uri);
      if (index === -1) {
        needDeleteRootList.push(rootFolder.uri);
      }
    }
    this.removeRootFolder(needDeleteRootList);

    let needAddRootList: DiskInfo[] = [];
    for (let diskInfo of diskInfoList) {
      let index = this.rootFolderList.findIndex(item => item.uri === diskInfo.uri);
      if (index === -1) {
        needAddRootList.push(diskInfo);
      }
    }
    this.addRootFolder(needAddRootList);
    this.lastFolderUri = this.pathPickerFolderDataSource.getLastFolderUri();
    HiLog.info(TAG, `sdUsbChange end: ${needDeleteRootList.length}, ${needAddRootList.length}`)
  }

  /**
   * 移除根目录，如拔掉U盘等
   * @param needDeleteRootList 需要移除的根目录uri列表
   */
  removeRootFolder(needDeleteRootList: string[]) {
    if (ArrayUtil.isEmpty(needDeleteRootList)) {
      return;
    }
    HiLog.infoPrivate(TAG, 'needDeleteRootList: ', JSON.stringify(needDeleteRootList));
    for (let rootUri of needDeleteRootList) {
      const rootInfoIndex = this.rootFolderList.findIndex(item => item.uri === rootUri);
      if (rootInfoIndex !== -1) {
        this.rootFolderList.splice(rootInfoIndex, 1);
      }
      let rootFolderIndex = this.pathPickerFolderDataSource.getIndex(rootUri);
      if (rootFolderIndex === -1) {
        continue
      }
      this.pathPickerFolderDataSource.removeAllSubFolder(rootUri, true)
      const selectIndex = this.pathPickerFolderDataSource.getIndex(this.selectUri);
      if (selectIndex !== -1) {
        continue
      }
      const newSelectIndex = rootFolderIndex - 1;
      if (newSelectIndex >= 0) {
        this.setChooseItem(this.pathPickerFolderDataSource.getData(newSelectIndex));
        this.scrollToSelectItem();
      }
    }
  }

  /**
   * 新增新目录，如插上U盘等
   * @param needAddRootList 需要新增的存储设备列表
   */
  addRootFolder(needAddRootList: DiskInfo[]) {
    if (ArrayUtil.isEmpty(needAddRootList)) {
      return;
    }
    HiLog.infoPrivate(TAG, 'needAddRootList: ', JSON.stringify(needAddRootList));
    for (let diskInfo of needAddRootList) {
      let folderData = PathPickerUtil.convertDiskInfoToFolderData(diskInfo);
      folderData = updateFolderNameAndFileNameResource(folderData, folderData.fileName,
        ObjectUtil.isNullOrUndefined(folderData.deviceType) ? 0 : folderData.deviceType as number);
      let addIndex = this.pathPickerFolderDataSource.getTreeMaxLocalIndex();
      HiLog.info(TAG, 'addIndex = ' + addIndex);
      this.pathPickerFolderDataSource.addData(addIndex, folderData);
      this.rootFolderList.splice(0, 0, folderData);
    }
  }

  removeEventListener(): void {
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    if (this.startModeOptions.isUxt()) {
      EventBus.off(Constant.EVENTS.PATH_PICKER_FOLDER_REFRESH, () => this.queryRootFolderData());
    }
  }

  addEventListener(): void {
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    if (this.startModeOptions.isUxt()) {
      EventBus.on(Constant.EVENTS.PATH_PICKER_FOLDER_REFRESH, () => this.queryRootFolderData());
    }
  }

  async aboutToAppear() {
    HiLog.info(TAG, 'PathSelectTree aboutToAppear');
    this.showHiddenItem = AppStorage.get<boolean>(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) ?? false;
    if (!AccessibilityManager.getInstance().getIsAccessibilityMode()) {
      toast($r('app.string.select_location'));
    }
    this.addEventListener();
    if (this.selectFilesList.length) {
      this.hasFolder = this.selectFilesList.some(item => item.isFolder);
      if (!this.hasFolder) {
        this.selectFilesList.forEach(file => this.allFileSize += file.size);
      }
      for (const file of this.selectFilesList) {
        if (file.isFolder) {
          this.selectFileUris.push(file.uri);
        }
      }
    }
    this.onSelectFolderChange();
    this.queryRootFolderData(this.startModeOptions.isUxt());
    if (AccessibilityManager.getInstance().getIsAccessibilityMode()) {
      // 无障碍模式下，首次进入PathSelectTree时不需要跳转到已选中的路径
      AppStorage.setOrCreate(AccessibilityStorageKey.PATH_SELECT_INIT_KEY, '1');
    }
  }

  aboutToDisappear() {
    HiLog.info(TAG, 'PathSelectTree aboutToDisappear');
    this.removeEventListener();
    TaskManager.getInstance().cancelExecutorTask(TaskPoolName.QUERY_PICK_PATH);
  }

  async queryRootFolderData(needFreshDeviceList: boolean = false): Promise<void> {
    const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList(needFreshDeviceList);
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      HiLog.error(TAG, 'storageDeviceList is empty')
      return;
    }
    HiLog.info(TAG, 'queryRootFolderData, rootFolder length: ' + storageDeviceList.length);
    this.rootFolderList = this.convertDiskInfoList2FolderDataList(storageDeviceList,
      this.startModeOptions.callerBundleName);
    // 查询并显示根目录
    this.pathPickerFolderDataSource.setData(this.rootFolderList);
    this.lastFolderUri = this.pathPickerFolderDataSource.getLastFolderUri();
    this.expendToTargetFolder(storageDeviceList, this.lastSelectFolderUri);
  }

  /**
   * 展开到指定的目录，如果是路径选择器拉起的，优先使用三方指定的目录
   */
  expendToTargetFolder(storageDeviceList: DiskInfo[], targetFolderUri: string = ''): void {
    HiLog.info(TAG, 'expendToTargetFolder');
    // 复制拉起picker选择当前文件父目录
    if (this.operationType === Constant.OPERATION_TYPE.PASTING) {
      targetFolderUri = FileUtil.getFileParentPathFromUri(this.selectFilesList[0].uri);
    }
    // 默认选择上次选择的目录
    if (StringUtil.isEmpty(targetFolderUri)) {
      targetFolderUri = AppStorage.get<string>(PreferenceConst.KEY.LAST_SELECT_FOLDER_URI) || '';
    }
    // 如果是文件保存场景需要展开三方传入的目录
    if (this.operationType === Constant.OPERATION_TYPE.SAVE && StringUtil.isEmpty(this.lastSelectFolderUri)) {
      const defaultPickFolderUri = AbilityCommonUtil.getPathDefaultPickDir(this.startModeOptions);
      if (!StringUtil.isEmpty(defaultPickFolderUri)) {
        targetFolderUri = defaultPickFolderUri;
      }
    }
    // 没有目标目录则选择内部存储根目录
    if (StringUtil.isEmpty(targetFolderUri)) {
      this.setDefaultRootSelected();
      return;
    }
    const targetFolderRootInfo =
      storageDeviceList.find((diskInfo: DiskInfo) => targetFolderUri.startsWith(diskInfo.uri))
    // 目标目录的根目录不存在则选择内部存储根目录
    if (!targetFolderRootInfo) {
      HiLog.warn(TAG, 'defaultExpandRootInfo does not exist.')
      this.setDefaultRootSelected();
      return;
    }
    HiLog.infoPrivate(TAG, 'targetFolderUri: ', targetFolderUri);
    this.querySubFolderList(targetFolderRootInfo.uri, Constant.FOLDER_LEVEL.MIN_LEVEL,
      PathPickerUtil.removeLastSeparator(targetFolderUri), this.selectFileUris);
  }

  async querySubFolderListFinish(parentUri: string, subFolderList: FolderData[], targetFolderUri: string = '',
    selectFilesMaxLevel: number = 0): Promise<void> {
    HiLog.info(TAG, 'querySubFolderListFinish: start');
    if (parentUri === Constant.MY_PHONE_URI) {
      let galleryFolder = new FolderData();
      galleryFolder.uri = VirtualUri.GALLERY;
      galleryFolder.level = 2;
      galleryFolder.parentUri = parentUri;
      galleryFolder.fileName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'));
      subFolderList.unshift(galleryFolder);
    }
    const parentFolderIndex = this.pathPickerFolderDataSource.getIndex(parentUri);
    if (parentFolderIndex === -1) {
      HiLog.warnPrivate(TAG, 'parentFolder is not find：', parentUri);
      return;
    }
    // 过滤掉应用沙箱目录 appdata
    if (parentUri.toLowerCase() === MyPhoneConstant.SYSTEM_URI.toLowerCase()) {
      subFolderList = subFolderList.filter(it => {
        if (it.uri === VirtualUri.APPDATA) {
          return false;
        }
        return true;
      });
    }
    const parentFolderInfo: FolderData = this.pathPickerFolderDataSource.getData(parentFolderIndex);
    // 递归获取文件夹下的所有子文件夹做成列表
    const allSubFolderList = PathPickerUtil.getAllSubFolderList(subFolderList, parentFolderInfo);
    HiLog.info(TAG, 'querySubFolderListFinish, subFolderList: ' + subFolderList.length + ', allSubFolderList: ' +
    allSubFolderList.length);
    if (!ArrayUtil.isEmpty(allSubFolderList)) {
      parentFolderInfo.subFolderList = subFolderList;
      // 将查询的所有子目录数据循环添加到列表
      this.pathPickerFolderDataSource.insertFolderToList(parentFolderIndex, allSubFolderList);

      if (!StringUtil.isEmpty(this.newFolderUri)) {
        HiLog.info(TAG, 'querySubFolderListFinish: create new folder');
        // 新建文件夹场景
        const newFolderIndex = subFolderList.findIndex(item => item.uri === this.newFolderUri);
        this.newFolderUri = '';
        this.setChooseItem(subFolderList[newFolderIndex]);
      } else if (!StringUtil.isEmpty(targetFolderUri)) {
        HiLog.info(TAG, 'querySubFolderListFinish: expand target folder');
        // 展开到指定目录场景
        const targetFolder = PathPickerUtil.getTargetFolderData(parentFolderInfo, targetFolderUri)
        this.setChooseItem(targetFolder);
      } else {
        HiLog.info(TAG, 'querySubFolderListFinish: setChooseItem');
        this.setChooseItem(parentFolderInfo);
      }
      this.scrollToSelectItem();
    } else {
      this.setChooseItem(parentFolderInfo);
    }
    parentFolderInfo.isLoading = false;
    parentFolderInfo.isExpend = true;
    this.pathPickerFolderDataSource.updateFolderItem(parentFolderInfo);
    this.lastFolderUri = this.pathPickerFolderDataSource.getLastFolderUri();
    this.selectFilesMaxLevel = selectFilesMaxLevel;
    // 无障碍播报"已到末级"
    if (AccessibilityManager.getInstance().getIsAccessibilityMode() && subFolderList.length === 0) {
      ThrottlingUtil.debounce(AccessibilityTAG,() => {
        AccessibilityManager.getInstance()
          .sendTextAnnouncedForAccessibilityNoInterrupt(ResourceUtil.getStringByResource($r('app.string.arrive_path_select_end_level')));
      }, Constant.TIMER_TIME.TIMER_500)
    }
    HiLog.info(TAG, 'querySubFolderListFinish: finish');
  }

  setChooseItem(selectFolderItem: FolderData): void {
    if (ObjectUtil.isNullOrUndefined(selectFolderItem)) {
      return;
    }
    this.selectUri = selectFolderItem.uri;
    this.selectName = selectFolderItem.fileNameResource ??
    UiUtil.translateFileNameByUri(selectFolderItem.uri, selectFolderItem.fileName, true);
    this.selectFolderLevel = selectFolderItem.level;
    this.subFolderNameList = selectFolderItem.subFolderList.map((item: FolderData) => item.fileName);
    if (this.startModeOptions.isUxt()) {
      this.lastSelectFolderUri = this.selectUri;
    }
  }

  scrollToSelectItem(): void {
    if (StringUtil.isEmpty(this.selectUri)) {
      return;
    }
    const index = this.pathPickerFolderDataSource.getIndex(this.selectUri);
    if (index === -1) {
      HiLog.error(TAG, 'scrollToSelectItem return due to index = -1');
      return;
    }
    if (index < this.folderListShowStartIndex || index > this.folderListShowEndIndex) {
      this.scroller.scrollToIndex(index, true, ScrollAlign.AUTO);
    }
  }

  setDefaultRootSelected(): void {
    if (ArrayUtil.isEmpty(this.rootFolderList)) {
      HiLog.warn(TAG, 'setDefaultRootSelected: root folder empty');
      return;
    }
    const rootFileData = this.rootFolderList.find((folderData: FolderData) => folderData.isLocalRootFolder())
    if (!rootFileData) {
      HiLog.warn(TAG, 'setDefaultRootSelected: rootFileData undefined');
      return;
    }
    HiLog.info(TAG, 'setDefaultRootSelected');
    this.querySubFolderList(rootFileData.uri, Constant.FOLDER_LEVEL.MIN_LEVEL);
  }

  /**
   * 新建文件成功后的回调
   * @param folderName 新建文件夹的名字
   * @param uri 文件夹uri
   */
  createFolderSuccess(folderName: string, uri: string): void {
    if (folderName === undefined) {
      HiLog.warn(TAG, 'Folder not created due to undefined folderName.');
      return;
    }
    PageUtil.refreshMyPhonePage();

    const parentFolderIndex = this.pathPickerFolderDataSource.getIndex(this.selectUri);
    if (parentFolderIndex === -1) {
      HiLog.warnPrivate(TAG, 'parentFolder is not find：', this.selectUri);
      return;
    }
    const parentFolderInfo: FolderData = this.pathPickerFolderDataSource.getData(parentFolderIndex);
    UEUtil.reportCreateNewFolder(EnumTransferUtil.transferUriToPageName(parentFolderInfo.uri), true);
    if (!parentFolderInfo.isExpend) {
      HiLog.warn(TAG, 'createFolderSuccess: parentFolderInfo is not Expend');
      this.querySubFolderList(this.selectUri, this.selectFolderLevel);
      return;
    }

    let newFolderData = new FolderData();

    const parentFolderPath = FileUtil.getPathFromUri(this.selectUri);
    const newFolderPath = parentFolderPath + '/' + folderName
    this.newFolderUri = FileUtil.getUriFromPath(newFolderPath);
    // 父目录展开时直接在其后追加
    newFolderData.fileName = folderName;
    newFolderData.uri = this.newFolderUri;
    newFolderData.parentUri = this.selectUri;
    newFolderData.isExpend = true;
    newFolderData.mtime = new Date().getTime();
    newFolderData.relativePath = newFolderPath;
    if (uri?.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      HiLog.warn(TAG, 'createFolderSuccess for gallery');
      newFolderData.relativePath = FileUtil.getPathFromUri(uri);
      this.newFolderUri = uri;
      newFolderData.uri = uri;
    }
    newFolderData.level = parentFolderInfo.level + 1;
    newFolderData.deviceType = parentFolderInfo.deviceType;
    this.pathPickerFolderDataSource.addData(parentFolderIndex + 1, newFolderData);
    parentFolderInfo.subFolderList.unshift(newFolderData);
    this.setChooseItem(newFolderData);
    // 图库新增文件夹不触发界面刷新
    if (this.startModeOptions.isUxt() && !this.selectUri.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      EventBus.emit(Constant.EVENTS.PATH_PICKER_FOLDER_REFRESH);
    }
  }

  onSelectFolderChange(): void {
    if (this.operationType === Constant.OPERATION_TYPE.MOVE) {
      this.operationTitle = $r('app.plural.move_dialog_title', this.selectFilesList.length,
        this.selectFilesList.length, this.selectName);
    } else {
      this.operationTitle =
        $r('app.plural.copy_dialog_title', this.selectFilesList.length, this.selectFilesList.length, this.selectName);
    }
  }

  /**
   * 获取本次拉起路径选择器的操作描述
   *
   * @param type 移动、复制
   * @param name toLocationName
   * @returns title
   */
  getOperationTitle(type: string, name: string): Resource {
    if (type === Constant.OPERATION_TYPE.MOVE) {
      return $r('app.plural.move_dialog_title', this.selectFilesList.length, this.selectFilesList.length, name);
    } else {
      return $r('app.plural.copy_dialog_title', this.selectFilesList.length, this.selectFilesList.length, name);
    }
  }

  /**
   * 是否可以创建文件夹，检查文件夹的层级是否大于20并且不是图库相册
   */
  isCreateFolderEnabled(): boolean {
    return this.selectFolderLevel < Constant.FOLDER_LEVEL.MAX_LEVEL &&
      !this.selectUri.startsWith(Constant.MediaLibrary_URI_HEAD);
  }

  // 是否可以点击确定
  isSubmitEnable() {
    return true;
  }

  /**
   * 点击文件夹后的处理
   * @param fileItem 当前选中的文件夹
   */
  onFolderItemClick(folderData: FolderData): void {
    HiLog.infoPrivate(TAG, `onFolderItemClick`,
      `uri: ${folderData.uri}, isLoading: ${folderData.isLoading}, isExpend: ${folderData.isExpend},
       deviceType: ${folderData.deviceType}`)
    // todo: 如果是图库目录、截图目录、录屏目录，做特殊提示

    if (folderData.isLoading || folderData.level > Constant.FOLDER_LEVEL.MAX_LEVEL) {
      HiLog.warn(TAG, 'current is loading or level reach MAX_LEVEL')
      return;
    }
    if (folderData.isExpend && !folderData.isEmptyFolder()) {
      this.pathPickerFolderDataSource.removeAllSubFolder(folderData.uri);
      folderData.isExpend = false;
      this.lastFolderUri = this.pathPickerFolderDataSource.getLastFolderUri();
    } else {
      this.querySubFolderList(folderData.uri, folderData.level, '', this.selectFileUris);
      folderData.isExpend = true;
    }
    this.setChooseItem(folderData);
    this.pathPickerFolderDataSource.setItemExpend(folderData.uri, folderData.isExpend)
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          this.builderHeaderButton();
          if (this.operationType === Constant.OPERATION_TYPE.SAVE) {
            // path_picker
            SaveFileComp({
              selectedFolderUri: this.selectUri,
              selectedFolderName: this.selectName,
              startModeOptions: this.startModeOptions
            })
          } else {
            this.builderSelectedFileInfo();
          }
        }
        .onAreaChange(() => {
          this.updateHeaderScrollable();
        })
        .id(PATH_SELECT_TREE_HEADER_ID)

        Row()
          .width('100%')
          .height($r('app.float.common_size4'))
          .backgroundColor($r('sys.color.ohos_id_color_subheading_separator'))

        List({ scroller: this.scroller }) {
          LazyForEach(this.pathPickerFolderDataSource, (item: FolderData, index) => {
            ListItem() {
              PathSelectTreeItem({
                folderItem: item,
                selectUri: this.selectUri,
                onItemClick: (folderData: FolderData) => this.onFolderItemClick(folderData),
                isLastFolder: this.lastFolderUri === item.uri,
              })
            }
          }, (item: FolderData) => JSON.stringify(item))
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .width('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: !this.isHeaderScrollable })
        .scrollBar(BarState.Off)
        .layoutWeight(this.isHeaderScrollable ? 0 : 1)
        .contentEndOffset(Constant.THREE_BUTTON_NAVIGATION_HEIGHT)
        .align(Alignment.TopStart)
        .onScrollIndex((start, end) => {
          this.folderListShowStartIndex = start;
          this.folderListShowEndIndex = end;
        })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .borderRadius({ topLeft: $r('app.float.common_size24'), topRight: $r('app.float.common_size24') })
    .id(PATH_SELECT_TREE_SCROLL_ID)
    .scrollBar(BarState.Off)
    .onAreaChange(() => {
      this.updateHeaderScrollable();
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: this.isHeaderScrollable })
  }

  getSecondImageBottom(): Resource {
    if (!ArrayUtil.isEmpty(this.selectFilesList) && this.selectFilesList.length > 1) {
      let secondFile = this.selectFilesList[1];
      let firstFile = this.selectFilesList[0];
      if (secondFile.isFolder && !firstFile.isFolder) {
        return $r('app.float.common_margin30');
      }
    }
    return $r('app.float.common_margin16');
  }

  @Builder
  builderSelectedFileInfo() {
    Row() {
      FileIconStackComp({
        selectFilesList: this.selectFilesList,
        isSaveFile: false,
        isOutsideFolded: this.isOutsideFolded
      })
        .margin({ end: LengthMetrics.resource($r('app.float.common_margin10')) })
      Column() {
        Text(this.operationTitle)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .id(CompId.DIALOG_TITLE)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .wordBreak(WordBreak.BREAK_ALL)
        // 不包含文件夹且非剪切板场景拉起时才展示文件总大小
        if (!this.hasFolder && this.operationType !== Constant.OPERATION_TYPE.PASTING) {
          Text($r('app.string.total', renderSize(this.allFileSize)))
            .fontSize($r('app.float.common_font_size14'))
            .opacity($r('app.float.common_opacity6'))
            .margin({ top: $r('app.float.common_margin2') })
            .id(CompId.DIALOG_DOCUMENT_MEMORY)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }.width('100%')
    .padding({
      right: $r('app.float.common_padding24'),
      left: $r('app.float.common_padding24'),
      bottom: $r('app.float.common_padding15')
    })
  }

  @Builder
  builderHeaderButton() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size18'))
          .draggable(false)
          .focusable(true)
          .id(CompId.LEFT_ICON)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.cancel')))
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .padding($r('app.float.common_size11'))
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .stateStyles({
        pressed: pressedStyles,
        normal: normalStyles
      })
      .onClick(() => {
        HiLog.info(TAG, 'user cancel path picker')
        if (this.operationType === Constant.OPERATION_TYPE.PASTING) {
          // 复制取消时没有目标页面
          this.pageName = DFX.PageName.UNKNOWN;
          this.addUEEvent(true);
        } else {
          AppStorage.delete(DFX.StorageKey.OPERATE_SOURCE);
          AppStorage.delete(DFX.StorageKey.OPERATE_PAGE);
          AppStorage.delete(DFX.StorageKey.OPERATE_TYPE);
        }
        if (this.startModeOptions.isUxt()) {
          EventBus.emit(Constant.EVENTS.CLOSE_UI_PATH_PICKER + this.startModeOptions.currentCreateTimeStamp);
          return;
        }
        EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
      })

      Blank()
      Button() {
        SymbolGlyph($r('sys.symbol.folder_badge_plus'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size24'))
          .draggable(false)
          .focusable(true)
          .id(CompId.NEW_DOCUMENT_ICON)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.addFolder')))
      .visibility(this.isOutsideFolded ? Visibility.None : Visibility.Visible)
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .type(ButtonType.Circle)
      .padding($r('sys.float.padding_level4'))
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .margin({ start: LengthMetrics.resource($r('app.float.common_margin2')) })
      .enabled(this.isCreateFolderEnabled())
      .onClick(() => {
        this.fileMkdirDialog.open()
      })

      Button() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size24'))
          .draggable(false)
          .focusable(true)
          .id(CompId.DIALOG_CONFIRM)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.confirm')))
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .type(ButtonType.Circle)
      .enabled(this.isSubmitEnable())
      .padding($r('sys.float.padding_level4'))
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .margin({ start: LengthMetrics.resource($r('app.float.common_margin8')) })
      .onClick(() => {
        this.confirm();
      })
    }.width('100%')
    .padding({
      top: $r('app.float.common_padding8'),
      right: $r('app.float.common_padding15'),
      bottom: $r('app.float.common_padding15'),
      left: $r('app.float.common_padding15')
    })
  }

  async confirm() {
    //剩余空间不足500M时，目标文件夹为本地的可增加内存的操作时需要弹框
    const freeSize = await PageUtil.getLocalFreeSpace();
    if (this.isInsufficientSpace(freeSize)) {
      return;
    }
    this.addUEEvent(false);
    TraceUtils.startTrace('PathSelectTree confirm');
    HiLog.infoPrivate(TAG, 'confirm selectUri: ', this.selectUri);
    CommonPreferenceUtil.setLastSelectFolderUri(this.selectUri);
    EventBus.emit(
      Constant.EVENTS.CLOSE_PATH_PICKER + (this.startModeOptions.isUxt() ? this.startModeOptions.currentCreateTimeStamp : ''),
      this.selectUri);
    HiLog.infoPrivate(TAG, 'confirm selectUri: end', this.selectUri);
    TraceUtils.finishTrace('PathSelectTree confirm');
  }

  showErrorDialog(mainContent: Resource) {
    let dialog: CustomDialogController = new CustomDialogController({
      builder: ConfirmTemplateDialog({
        title: $r('app.string.save_file'),
        content: mainContent,
        firstButtonText: $r('app.string.get_it'),
        firstButtonCallback: (): void => {
          HiLog.info(TAG, 'close dialog');
          dialog.close()
        },
      }),
      autoCancel: false
    });
    dialog.open();
  }

  /**
   * 将存储设备信息列表转化成文件夹列表
   * @param storageDeviceList 存储设备信息列表
   * @returns Array<FolderData>
   */
  convertDiskInfoList2FolderDataList(storageDeviceList: DiskInfo[], callerBundleName: string): FolderData[] {
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      return [];
    }
    let rootFolderList: FolderData[] = [];
    for (let rootInfo of storageDeviceList) {
      if (callerBundleName === Constant.FILE_MANAGER_BUNDLE_NAME && !AppStorage.get<boolean>('isUploadPicker')) {
        if (rootInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
          continue;
        }
      }
      let folderData = PathPickerUtil.convertDiskInfoToFolderData(rootInfo);
      folderData = updateFolderNameAndFileNameResource(folderData, rootInfo.description, rootInfo.deviceType);
      rootFolderList.push(folderData);
    }
    HiLog.infoPrivate(TAG, 'rootFolderList:', JSON.stringify(rootFolderList));
    return rootFolderList;
  }

  /**
   * 更新picker Header 是否可以滚动
   */
  updateHeaderScrollable(): void {
    try {
      let pathSelectTreeHeight: number = 100;
      if (this.pathPickerFolderDataSource.totalCount() > 0 && this.scroller) {
        pathSelectTreeHeight = 2 * this.scroller.getItemRect(0).height;
      }
      const scrollComponentInfo: componentUtils.ComponentInfo =
        componentUtils.getRectangleById(PATH_SELECT_TREE_SCROLL_ID);
      const pathSelectTreeHeaderInfo: componentUtils.ComponentInfo =
        componentUtils.getRectangleById(PATH_SELECT_TREE_HEADER_ID);
      // 判断底部的路径Picker的区域是否小于2*treeItem的高度，若是则只让Header模块可以滚动，否则不可滚动
      if (px2vp(scrollComponentInfo.size.height - pathSelectTreeHeaderInfo.size.height) < pathSelectTreeHeight) {
        this.isHeaderScrollable = true;
      } else {
        this.isHeaderScrollable = false;
      }
    } catch (e) {
      HiLog.error(TAG, `updateHeaderScrollable error: ${JSON.stringify(e)}}`);
    }
  }

  private querySubFolderList(folderUri: string, level: number, targetFolderUri: string = '',
    selectFileUris: string[] = []): void {
    this.pathPickerFolderDataSource.setItemLoading(folderUri, true);
    this.subFolderNameList = [];
    let task: QuerySubFolderTask = new QuerySubFolderTask(
      (subFolderList: FolderData[], parentUri: string, targetFolder: string = '', selectFilesMaxLevel: number = 0) =>
      this.querySubFolderListFinish(parentUri, subFolderList, targetFolder, selectFilesMaxLevel),
      folderUri, targetFolderUri, level + 1, level === Constant.FOLDER_LEVEL.MIN_LEVEL, selectFileUris,
      this.showHiddenItem, getContext());
    TaskManager.getInstance().execute(task, 2);
  }

  private isInsufficientSpace(freeSize: number): boolean {
    const selectList = Constant.OPERATION_TYPE.PASTING === this.operationType ? this.selectFilesList : [];
    if ([Constant.OPERATION_TYPE.PASTING].includes(this.operationType) &&
    FileUtil.isLocalPath(this.selectUri) && PageUtil.isInsufficientSpace(freeSize, selectList)) {
      EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
      EventBus.emit(Constant.EVENTS.SHOW_INSUFFICIENT_DISK_SPACE_DIALOG, this.getReasonType());
      HiLog.warn(TAG, `the remaining memory is insufficient in ${this.operationType}`);
      return true;
    }
    return false;
  }

  /**
   * 获取上报参数reasonType的值
   * @returns DFX.ReasonType 触发弹框的操作类型
   */
  private getReasonType(): DFX.ReasonType {
    if (this.operationType === Constant.OPERATION_TYPE.PASTING) {
      return DFX.ReasonType.PASTE;
    }
    return DFX.ReasonType.ERR_CODE;
  }

  //当选中的所有文件或文件夹有一个不属于图库时，则来源页面非图库，否则来源页面为图库
  private isFromGallery(): boolean {
    for (let item of this.selectFilesList) {
      if (!(item.isGallery || FileUtil.isGalleryAddress(item.uri))) {
        return false;
      }
    }
    return true;
  }

  private addUEEvent(isCancel: boolean): void {
    if (this.operationType !== Constant.OPERATION_TYPE.SAVE) {
      UEUtil.reportPickerOper(DFX.PickerMode.PATH_PICKER, this.selectFilesList.length ?? 1,
        this.startModeOptions.callerBundleName);
    }
    switch (this.operationType) {
      case Constant.OPERATION_TYPE.PASTING:
      case Constant.OPERATION_TYPE.MOVE: {
        const operateSource = AppStorage.get<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE);
        const operatePage =
          this.isFromGallery() ? DFX.PageName.GALLERY : AppStorage.get<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE);
        const operateType = AppStorage.get<DFX.PasteType>(DFX.StorageKey.OPERATE_TYPE);
        if ((!operateSource && !operateType) || !operatePage) {
          return;
        }
        if (operateType) {
          UEUtil.reportPasteFile(EnumTransferUtil.transferUriToPageName(this.selectUri), operateType,
            this.selectFilesList.length);
        } else {
          const type =
            this.operationType === Constant.OPERATION_TYPE.PASTING ? DFX.CopyMoveType.COPY : DFX.CopyMoveType.MOVE;
          UEUtil.reportCopyMoveFile(type, operateSource, operatePage,
            isCancel ? DFX.PageName.UNKNOWN : EnumTransferUtil.transferUriToPageName(this.selectUri),
            this.selectFilesList.length);
        }
        AppStorage.delete(DFX.StorageKey.OPERATE_SOURCE);
        AppStorage.delete(DFX.StorageKey.OPERATE_PAGE);
        AppStorage.delete(DFX.StorageKey.OPERATE_TYPE);
        break;
      }
      default: {
        HiLog.warn(TAG, `no need to add UEEvent: ${this.operationType}`);
      }
    }
  }
}

