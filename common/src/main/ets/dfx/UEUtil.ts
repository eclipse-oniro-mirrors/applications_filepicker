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
import { AppConfig } from '../config/AppConfig';
import { HiSysEventUtil } from './HiSysEventUtil';
import lazy { hiSysEvent } from '../../../../indexLazyLoadTs';
import { DFX } from './const/DFXConst';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalHolder } from '../global/GlobalHolder';
import { GlobalKey } from '../global/GlobalKey';
import { StringUtil } from '../utils/StringUtil';
import { Want } from '@kit.AbilityKit';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from './HiLog';

const UNKNOWN = 'UNKNOWN';
const TAG = 'UEUtil';

export class UEUtil {
  /**
   * 上报事件：切换排序规则
   * @param sortType 排序类型
   * @param isAsc 是否为升序
   * @param page 操作页面
   * @param isPicker 是否在picker中操作
   */
  public static reportSortRuleChange(sortType: DFX.SortType, isAsc: boolean, page: DFX.PageName,
    isPicker: boolean): void {
    let params: object = {
      SORT_TYPE: sortType,
      IS_ASC: isAsc,
      OPERATE_PAGE: page,
      IS_PICKER: isPicker
    };
    UEUtil.reportEventUE(DFX.UEEvent.SORT_RULE_CHANGE, params);
  }

  /**
   * 上报事件：切换文件视图
   * @param current 当前视图类型
   * @param switchTo 切换到的视图类型
   * @param operPage 操作页面
   * @param isPicker 是否在picker中操作
   */
  public static reportFileViewChange(current: DFX.ViewType, switchTo: DFX.ViewType, operPage: DFX.PageName,
    isPicker: boolean) {
    let params: object = {
      CURRENT: current,
      SWITCH_TO: switchTo,
      OPERATE_PAGE: operPage,
      IS_PICKER: isPicker
    };
    UEUtil.reportEventUE(DFX.UEEvent.FILE_VIEW_CHANGE, params);
  }

  /**
   * 上报事件：浏览页编辑态改变
   * @param editStatus 编辑状态，打开或完成
   */
  public static reportEditModeChange(editStatus: DFX.EditStatus): void {
    let params: object = {
      EDIT_STATUS: editStatus
    };
    UEUtil.reportEventUE(DFX.UEEvent.EDIT_MODE_CHANGE, params);
  }

  /**
   * 上报事件：打开设置弹窗
   */
  public static reportShowSetting(): void {
    UEUtil.reportEventUE(DFX.UEEvent.SHOW_SETTING, {});
  }

  /**
   * 上报事件：进入页面
   * @param pageName 进入的页面名称
   */
  public static reportEnterPage(pageName: DFX.PageName): void {
    let params: object = {
      PAGE_NAME: pageName
    };
    UEUtil.reportEventUE(DFX.UEEvent.ENTER_PAGE, params);
  }

  /**
   * 上报事件：来源项操作
   * @param operateType 操作类型
   * @param sourceName 来源名称
   */
  public static reportSourceItemOper(operateType: DFX.SourceItemOperType, sourceName: string): void {
    let params: object = {
      OPERATE_TYPE: operateType,
      SOURCE_NAME: sourceName
    };
    UEUtil.reportEventUE(DFX.UEEvent.SOURCE_ITEM_OPERATE, params);
  }

  /**
   * 上报事件：移动网络通知
   * @param tipMode 通知类型
   */
  public static reportCellularTip(tipMode: DFX.CellularTipMode): void {
    let params: object = {
      CELLULAR_TIP_MODE: tipMode
    };
    UEUtil.reportEventUE(DFX.UEEvent.CELLULAR_TIP, params);
  }

  /**
   * 上报事件：小图片过滤
   * @param filterSize 过滤大小
   */
  public static reportSmallImageFilter(filterSize: DFX.ImageFilterSize | number): void {
    let params: object = {
      FILTER_SIZE: filterSize
    };
    UEUtil.reportEventUE(DFX.UEEvent.SMALL_IMAGE_FILTER, params);
  }

  /**
   * 上报事件：显示隐藏文件
   * @param isShow
   */
  public static reportShowHiddenFile(isShow: boolean): void {
    let params: object = {
      IS_SHOW: isShow
    };
    UEUtil.reportEventUE(DFX.UEEvent.SHOW_HIDDEN_FILE, params);
  }

  /**
   * 上报事件：新建文件夹
   * @param operatePage 操作页面
   * @param isPicker 是否在picker中操作
   */
  public static reportCreateNewFolder(operatePage: DFX.PageName, isPicker: boolean): void {
    let params: object = {
      OPERATE_PAGE: operatePage,
      IS_PICKER: isPicker
    };
    UEUtil.reportEventUE(DFX.UEEvent.CREATE_NEW_FOLDER, params);
  }

  /**
   * 上报事件：打开文件
   * @param openMode 打开模式
   * @param fileSuffix 文件后缀
   */
  public static reportOpenFile(openMode: DFX.FileOpenMode, fileSuffix: string): void {
    let params: object = {
      OPEN_MODE: openMode,
      FILE_SUFFIX: fileSuffix
    };
    UEUtil.reportEventUE(DFX.UEEvent.OPEN_FILE, params);
  }

  /**
   * 上报事件：文件收藏
   * @param operType 收藏类型，收藏或取消收藏
   * @param operSource 操作来源
   * @param fileNum 文件数量
   */
  public static reportFileFavorite(operType: DFX.FavoriteOperType, operSource: DFX.OperateSource,
    fileNum: number): void {
    let params: object = {
      OPERATE_TYPE: operType,
      OPERATE_SOURCE: operSource,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.FILE_FAVORITE, params);
  }

  /**
   * 上报事件：显示分享弹窗
   * @param operSource 操作来源
   * @param fileNum 文件数量
   */
  public static reportShowShareDialog(operSource: DFX.OperateSource, fileNum: number): void {
    let params: object = {
      OPERATE_SOURCE: operSource,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.SHOW_SHARE_DIALOG, params);
  }

  /**
   * 上报事件：复制移动文件
   * @param operType 操作类型
   * @param operSource 操作来源
   * @param operPage 操作页面
   * @param destPage 目标页面
   * @param fileNum 文件数量
   */
  public static reportCopyMoveFile(operType: DFX.CopyMoveType, operSource: DFX.OperateSource, operPage: DFX.PageName,
    destPage: DFX.PageName, fileNum: number): void {
    let params: object = {
      OPERATE_TYPE: operType,
      OPERATE_SOURCE: operSource,
      OPERATE_PAGE: operPage,
      DEST_PAGE: destPage,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.COPY_MOVE_FILE, params);
  }

  /**
   * 上报事件：粘贴文件
   * @param operPage 操作页面
   * @param operType 操作类型，包括跨应用粘贴弹窗、长按空白处粘贴
   * @param fileNum 文件数量
   */
  public static reportPasteFile(operPage: DFX.PageName, operType: DFX.PasteType, fileNum: number): void {
    let params: object = {
      OPERATE_PAGE: operPage,
      OPERATE_TYPE: operType,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.PASTE_FILE, params);
  }

  /**
   * 上报事件：重命名文件
   * @param operPage 操作页面
   */
  public static reportRenameFile(operPage: DFX.PageName): void {
    // 外部拉起的场景
    let callerBundleName = UEUtil.getCallerBundleName();
    let params: object = {
      OPERATE_PAGE: operPage,
      CALLER_BUNDLE_NAME: callerBundleName
    };
    UEUtil.reportEventUE(DFX.UEEvent.RENAME_FILE, params);
  }

  /**
   * 上报删除事件
   * @param operPage 操作页面
   * @param deleteType 删除类型
   * @param operSource 操作来源
   * @param fileNum 文件数量
   */
  public static reportDeleteFile(operPage: DFX.PageName, deleteType: DFX.DeleteType, operSource: DFX.OperateSource,
    fileNum: number): void {
    let callerBundleName = UEUtil.getCallerBundleName();
    let params: object = {
      OPERATE_PAGE: operPage,
      OPERATE_TYPE: deleteType,
      OPERATE_SOURCE: operSource,
      FILE_NUM: fileNum,
      CALLER_BUNDLE_NAME: callerBundleName
    };
    UEUtil.reportEventUE(DFX.UEEvent.DELETE_FILE, params);
  }

  /**
   * 上报事件：还原文件
   * @param operSource 操作来源
   * @param fileNum 文件数量
   */
  public static reportRestoreFile(operSource: DFX.OperateSource, fileNum: number): void {
    let params: object = {
      OPERATE_SOURCE: operSource,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.RESTORE_FILE, params);
  }

  /**
   * 上报事件：查看文件详情
   * @param isFolder 是否为文件夹
   */
  public static reportFileDetail(isFolder: boolean): void {
    let params: object = {
      IS_FOLDER: isFolder
    };
    UEUtil.reportEventUE(DFX.UEEvent.FILE_DETAIL, params);
  }

  /**
   * 上报事件：打印文件
   * @param fileSuffix 文件后缀
   */
  public static reportPrintFile(fileSuffix: string): void {
    let params: object = {
      FILE_SUFFIX: fileSuffix
    };
    UEUtil.reportEventUE(DFX.UEEvent.PRINT_FILE, params);
  }

  /**
   * 上报事件：拖拽文件
   * @param dragType 拖拽类型
   * @param operPage 操作页面
   * @param fileNum 文件数量
   */
  public static reportDragFile(dragType: DFX.DragType, operPage: DFX.PageName, fileNum: number): void {
    let params: object = {
      DRAG_TYPE: dragType,
      OPERATE_PAGE: operPage,
      FILE_NUM: fileNum
    };
    UEUtil.reportEventUE(DFX.UEEvent.DRAG_FILE, params);
  }

  /**
   * 上报事件：进入大文件列表
   * @param enterType
   */
  public static reportEnterBigFileList(enterType: DFX.FileCleanListEnterType): void {
    let params: object = {
      OPERATE_TYPE: enterType
    };
    UEUtil.reportEventUE(DFX.UEEvent.ENTER_BIG_FILE_LIST, params);
  }

  /**
   * 上报事件：进入本地垃圾文件列表
   * @param enterType
   */
  public static reportEnterTrashFileList(enterType: DFX.FileCleanListEnterType): void {
    let params: object = {
      ENTER_TYPE: enterType
    };
    UEUtil.reportEventUE(DFX.UEEvent.ENTER_LOCAL_TRASH_FILE_LIST, params);
  }

  /**
   * 上报事件：删除垃圾文件
   * @param fileSize 文件大小
   * @param fileNum 文件数量
   * @param deleteTime 删除时间戳
   */
  public static reportDelTrashFile(fileSize: number, fileNum: number, deleteTime: string): void {
    let params: object = {
      FILE_SIZE: fileSize,
      FILE_NUM: fileNum,
      DELETE_TIME: deleteTime
    };
    UEUtil.reportEventUE(DFX.UEEvent.DELETE_LOCAL_TRASH_FILE, params);
  }

  /**
   * 上报事件： 重复文件扫描
   * @param fileSize 重复文件大小
   * @param fileGroups 重复文件组数
   * @param isSuccess 扫描结果
   * @param errorCode 错误码
   */
  public static reportDuplicateFileScan(fileSize: number, fileGroups: number, isSuccess: boolean,
    errorCode: number): void {
    let params: object = {
      FILE_SIZE: fileSize,
      FILE_GROUPS: fileGroups,
      IS_SUCCESS: isSuccess,
      ERROR_CODE: errorCode,
    }
    UEUtil.reportEventUE(DFX.UEEvent.DUPLICATE_FILE_SCAN, params);
  }

  /**
   * 上报事件：进入重复文件清理列表界面
   */
  public static reportEnterDuplicateFileList(): void {
    UEUtil.reportEventUE(DFX.UEEvent.ENTER_DUPLICATE_FILE_LIST, {});
  }

  /**
   * 上报事件：删除重复文件
   * @param fileSize 文件大小
   * @param fileNum 文件数量
   * @param deleteTime 删除时间戳
   * @param isSuccess 成功/失败
   * @param errorCode 错误码
   */
  public static reportDelDuplicateFile(fileSize: number, fileNum: number, deleteTime: string, isSuccess: boolean,
    errorCode: number): void {
    let params: object = {
      FILE_SIZE: fileSize,
      FILE_NUM: fileNum,
      DELETE_TIME: deleteTime,
      IS_SUCCESS: isSuccess,
      ERROR_CODE: errorCode
    };
    UEUtil.reportEventUE(DFX.UEEvent.DELETE_DUPLICATE_FILE, params);
  }

  /**
   * 上报事件：重复文件详情信息
   * @param fileType：文件类型 图片: IMAGE 视频：VIDEO 文档：DOC 音频：AUDIO 压缩包：COMPRESS 其他：OTHER
   * @param fileCount : 文件总数
   * @param groupCount : 分组总数
   */
  public static reportDuplicateFileDetail(fileType: string, fileCount: number, groupCount: number): void {
    let params: object = {
      FILE_TYPE: fileType,
      FILE_COUNT: fileCount,
      GROUP_COUNT: groupCount,
    };
    UEUtil.reportEventUE(DFX.UEEvent.DUPLICATE_FILE_DETAILS, params);
  }

  /**
   * 上报事件：多选文件
   * @param operSource 操作来源
   * @param operPage 操作页面
   */
  public static reportMultiSelect(operSource: DFX.OperateSource, operPage: DFX.PageName): void {
    let params: object = {
      OPERATE_SOURCE: operSource,
      OPERATE_PAGE: operPage
    };
    UEUtil.reportEventUE(DFX.UEEvent.FILE_MULTI_SELECT, params);
  }

  /**
   * 上报事件：全选或取消全选
   * @param operPage 操作页面
   * @param operType 操作类型
   */
  public static reportSelectOrDeselectAll(operPage: DFX.PageName, operType: DFX.SelectAllType): void {
    let params: object = {
      OPERATE_PAGE: operPage,
      OPERATE_TYPE: operType
    };
    UEUtil.reportEventUE(DFX.UEEvent.SELECT_OR_DESELECT_ALL, params);
  }

  /**
   * 上报事件：滑动多选
   * @param operPage 操作页面
   * @param isPicker 是否在picker中操作
   */
  public static reportSlideSelect(operPage: DFX.PageName, isPicker: boolean): void {
    let params: object = {
      OPERATE_PAGE: operPage,
      IS_PICKER: isPicker
    };
    UEUtil.reportEventUE(DFX.UEEvent.SLIDE_SELECT, params);
  }

  /**
   * 上报事件：进入图库相册
   * @param albumType 主相册类型
   * @param subAlbumType 子相册类型
   * @param enterType 进入相册方式
   */
  public static reportEnterAlbum(albumType: DFX.AlbumType, subAlbumType: DFX.SubAlbumType,
    enterType: DFX.EnterAlbumType): void {
    let params: object = {
      ALBUM_TYPE: albumType,
      ALBUM_SUB_TYPE: subAlbumType,
      ENTER_TYPE: enterType
    };
    UEUtil.reportEventUE(DFX.UEEvent.ENTER_ALBUM, params);
  }

  /**
   * 上报事件：拉起文管、picker
   * @param abilityName 实例名称
   * @param instancesNum 实例数量
   * @param callSource 实例拉起来源，即拉起方包名
   */
  public static reportCreateAbility(abilityName: DFX.AbilityName, callSource: string): void {
    let params: object = {
      ABILITY_NAME: abilityName,
      // 拉起实例数已废弃，下批点位更新后删除INSTANCES_NUM字段
      INSTANCES_NUM: 0,
      CALL_SOURCE: callSource
    };
    UEUtil.reportEventUE(DFX.UEEvent.CREATE_ABILITY, params);
  }

  /**
   * 上报事件：外接存储设备操作
   * @param operType
   */
  public static reportExternalOper(operType: DFX.ExternalOperType): void {
    let params: object = {
      OPERATE_TYPE: operType
    };
    UEUtil.reportEventUE(DFX.UEEvent.EXTERNAL_STORAGE_OPERATION, params);
  }

  /**
   * 上报事件：picker打开
   * @param pickerMode picker模式
   * @param fileNum 文件数量
   * @param callSource picker拉起来源
   */
  public static reportPickerOper(pickerMode: DFX.PickerMode, fileNum: number, callSource: string): void {
    let params: object = {
      PICKER_MODE: pickerMode,
      FILE_NUM: fileNum,
      CALL_SOURCE: callSource
    };
    UEUtil.reportEventUE(DFX.UEEvent.OPEN_PICKER, params);
  }

  /**
   * 上报事件：创建下载目录
   * @param bundleName 包名
   */
  public static reportCreateDownloadFolder(bundleName: string): void {
    let params: object = {
      BUNDLE_NAME: bundleName
    };
    UEUtil.reportEventUE(DFX.UEEvent.CREATE_DOWNLOAD_FOLDER, params);
  }

  /**
   * 上报事件：最近浏览底部Tab栏切换
   * @param tabName tab名称
   */
  public static reportBottomTabClick(tabName: DFX.BottomTabName): void {
    let params: object = {
      TAB_NAME: tabName
    };
    UEUtil.reportEventUE(DFX.UEEvent.BOTTOM_TAB_CLICK, params);
  }

  /**
   * 上报事件：进入帮助与客服页面
   */
  public static reportShowWiseSupportHelp(): void {
    UEUtil.reportEventUE(DFX.UEEvent.QUESTIONS_AND_SUGGESTIONS, {});
  }

  /**
   * 上报事件：设置公共操作
   * @param operType 操作类型
   */
  public static reportSettingCommonOper(operType: DFX.SettingCommonOperType): void {
    let params: object = {
      OPERATE_TYPE: operType
    };
    UEUtil.reportEventUE(DFX.UEEvent.SETTING_COMMON_OPERATION, params);
  }

  /**
   * 上报事件：点击面包屑导航
   * @param operPage 操作页面
   */
  public static reportAddressBarClick(operPage: DFX.PageName): void {
    let params: object = {
      OPERATE_PAGE: operPage
    };
    UEUtil.reportEventUE(DFX.UEEvent.CLICK_ADDRESS_BAR, params);
  }

  /**
   * 上报事件： 通用打点事件
   */
  public static reportGeneralOperation(module: DFX.OperateModule, operateType: DFX.OperateType): void {
    let params: object = {
      OPERATE_MODULE: module,
      OPERATE_TYPE: operateType
    };
    UEUtil.reportEventUE(DFX.UEEvent.USER_GENERAL_OPERATION, params);
  }

  /**
   * 上报UE事件
   * @param eventName 事件名称
   * @param params 事件参数
   */
  private static reportEventUE(eventName: string, params: object): void {
    // UE打点中都需要添加固定参数PNAMEID: 包名，PVERSIONID: 版本号
    const paramUE = Object.assign({
      PNAMEID: AppConfig.APP_PACKAGE_NAME,
      PVERSIONID: AppConfig.APP_VERSION
    }, params);
    HiSysEventUtil.reportEvent(eventName, paramUE, hiSysEvent.EventType.BEHAVIOR, DFX.DOMAIN_UE);
  }

  private static getCallerBundleName(): string {
    let name = GlobalHolder.getInstance()
      .getObject<string>(GlobalKey.OPEN_MEDIA_CALLER_BUNDLE_NAME);
    return StringUtil.isEmpty(name) ? AppConfig.APP_PACKAGE_NAME : name;
  }

  /**
   * 上报事件：体验500M优化的弹框
   */
  public static reportShowLowMemoryDialog(reasonType: DFX.ReasonType, isCancel: boolean = true): void {
    const params: object = { REASON_TYPE: reasonType, IS_CANCEL: isCancel };
    UEUtil.reportEventUE(DFX.UEEvent.SHOW_LOW_MEMORY_DIALOG, params);
  }

  /**
   * 上报事件：设置为壁纸
   * @param operateType 操作来源
   * @param fileSource 设置的图片文件来源
   */
  public static reportSetWallpaper(operSource: DFX.OperateSource, fileSource: DFX.FileSource): void {
    const params: object = { OPERATE_TYPE: operSource, FILE_SOURECE: fileSource };
    UEUtil.reportEventUE(DFX.UEEvent.SET_AS_WALLPAPER, params);
  }

  /**
   * 上报事件：浏览页显示或隐藏位置中的项目
   * @param operType 操作类型，显示或隐藏位置项
   * @param locationName 操作的界面名称
   */
  public static reportLocationItemOper(operType: DFX.LocationItemOperType, locationName: DFX.PageName): void {
    const params: object = { OPERATE_TYPE: operType, LOCATION_NAME: locationName };
    UEUtil.reportEventUE(DFX.UEEvent.LOCATION_ITEM_OPERATE, params);
  }

  /**
   * 上报事件：抽屉模式切换
   * @param current: 当前的抽屉模式
   * @param target: 切换后的抽屉模式
   * @param operatePage: 执行的页面
   */
  public static reportDrawerModeChange(current: DFX.DrawerMode, target: DFX.DrawerMode,
    operatePage: DFX.PageName): void {
    const params: object = { CURRENT: current, SWITCH_TO: target, OPERATE_PAGE: operatePage };
    UEUtil.reportEventUE(DFX.UEEvent.DRAWER_MODE_CHANGE, params);
  }

  /**
   * filepicker选择文件参数记录
   * @param want: 拉起filepicker传入的请求
   * */
  public static reportPickerSelectParamsRecord(want: Want): void {
    if (!want) {
      HiLog.error(TAG, 'want undefined, early return');
      return;
    }
    const pickerType: string = want.parameters?.key_pick_type as string;
    const hasPickerTypeList: boolean = !ObjectUtil.isNullOrUndefined(want.parameters?.key_picker_type);
    const multiAuthMode: boolean = want.parameters?.key_mult_auth_mode as boolean;
    const multiAuthFilesNum: number = (ObjectUtil.toArray<string>(want.parameters?.key_mult_uri_arr) ?? []).length;
    const mergeTypeMode: number = want.parameters?.key_merge_type_mode as number ?? 0;
    const hasThemeColor: boolean = !ObjectUtil.isNullOrUndefined(want.parameters?.key_theme_color_mode);
    const hasFileSuffixFilter: boolean =
      (ObjectUtil.toArray<string>(want.parameters?.key_file_suffix_filter) ?? []).length > 0;
    const maxSelectNum: number = want.parameters?.key_pick_num as number;
    const selectMode: number = want.parameters?.key_select_mode as number;
    const authMode: boolean = want.parameters?.key_auth_mode as boolean;
    const callerBundleName: string = want.parameters?.['ohos.aafwk.param.callerBundleName'] as string;
    const hasPickerDirPath: boolean = !StringUtil.isEmpty(want.parameters?.key_pick_dir_path as string);
    const params: object = {
      PICKER_TYPE: pickerType,
      HAS_PICKER_TYPE_LIST: hasPickerTypeList,
      MULTI_AUTH_MODE: multiAuthMode,
      MULTI_AUTH_MODE_NUM: multiAuthFilesNum,
      MERGE_TYPE_MODE: mergeTypeMode,
      HAS_THEME_COLOR: hasThemeColor,
      HAS_FILE_SUFFIX_FILTER: hasFileSuffixFilter,
      PICKER_NUM: maxSelectNum,
      SELECT_MODE: selectMode,
      AUTH_MODE: authMode,
      CALLER_BUNDLE_NAME: callerBundleName,
      HAS_PICKER_DIR_PATH: hasPickerDirPath
    };
    UEUtil.reportEventUE(DFX.UEEvent.PARSE_PICKER_SELECT_PARAMS, params);
  }

  public static reportPickerSaveParamsRecord(want: Want): void {
    if (!want) {
      HiLog.error(TAG, 'want undefined, early return');
      return;
    }
    const saveFilesNum: number = (ObjectUtil.toArray<string>(want.parameters?.key_pick_file_name) ?? []).length;
    const hasFileSuffixChoices: boolean =
      ObjectUtil.toArray<string>(want.parameters?.key_file_suffix_choices).length > 0;
    const callerBundleName: string = want.parameters?.['ohos.aafwk.param.callerBundleName'] as string;
    const hasPickerDirPath: boolean = !StringUtil.isEmpty(want.parameters?.key_pick_dir_path as string);
    const pickerType: string = want.parameters?.key_pick_type as string;
    const params: object = {
      FILE_NAME_NUM: saveFilesNum,
      HAS_FILE_SUFFIX_CHOICES: hasFileSuffixChoices,
      CALLER_BUNDLE_NAME: callerBundleName,
      HAS_PICKER_DIR_PATH: hasPickerDirPath,
      PICKER_TYPE: pickerType
    };
    UEUtil.reportEventUE(DFX.UEEvent.PARSE_PICKER_SAVE_PARAMS, params);
  }
}