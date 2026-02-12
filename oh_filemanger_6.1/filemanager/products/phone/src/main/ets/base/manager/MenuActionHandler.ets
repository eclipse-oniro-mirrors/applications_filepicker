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
  AccessibilityManager,
  Constant,
  DFX,
  EventBus,
  FavoriteDbManager,
  FileInfo,
  HiLog,
  MenuInfo,
  MenuItemName,
  MenuUtil,
  ObjectUtil,
  ResourceUtil,
  toast,
  UEUtil
} from '@ohos/common';

export class MenuActionHandler {
  private TAG: string = 'MenuActionHandler';
  private menuNames: Set<MenuItemName> = new Set<MenuItemName>();
  private handlers: Map<MenuItemName, Function> = new Map([
    [MenuItemName.FAVORITE, (menuInfo: MenuInfo) => {
      this.handleFavorite(menuInfo)
    }],
    [MenuItemName.UN_FAVORITE, (menuInfo: MenuInfo) => {
      this.handleUnFavorite(menuInfo)
    }],
    [MenuItemName.SET_RINGTONE, (menuInfo: MenuInfo) => {
      this.handleSetRingtone(menuInfo)
    }],
    [MenuItemName.RESTORE, (menuInfo: MenuInfo) => {
      this.handleRestore(menuInfo)
    }]
  ]);
  private handleMenuActionBind: Function =
    (menuInfo: MenuInfo): void => this.handleMenuAction(menuInfo);
  // 后面由地址管理管理取代, Constant.FROM_TYPE
  private fromPage: string;
  private menuActionCallback?: Function = undefined;

  constructor(fromPage: string) {
    this.fromPage = fromPage;
  }

  public refreshFromPage(fromPage: string) {
    this.fromPage = fromPage;
  }

  public registerMenuEvent(menuNames: Array<MenuItemName>, menuActionCallback?: Function) {
    if (this.menuActionCallback) {
      HiLog.warn(this.TAG, 'already registered');
      return;
    }
    HiLog.info(this.TAG, 'registerMenuEvent');
    this.menuNames = new Set<MenuItemName>(menuNames);
    EventBus.on(Constant.EVENTS.MENU_CLICK, this.handleMenuActionBind, true)
    if (menuActionCallback) {
      this.menuActionCallback = menuActionCallback;
    }
  }

  public unregisterMenuEvent() {
    HiLog.info(this.TAG, 'unregisterMenuEvent');
    this.menuNames.clear();
    EventBus.off(Constant.EVENTS.MENU_CLICK, this.handleMenuActionBind)
  }

  public againRegisterMenuEvent() {
    EventBus.on(Constant.EVENTS.MENU_CLICK, this.handleMenuActionBind, true)
  }

  public handleMenuAction(menuInfo: MenuInfo) {
    if (ObjectUtil.isNullOrUndefined(menuInfo)) {
      HiLog.error(this.TAG, 'undefined menu info');
      return;
    }
    HiLog.info(this.TAG, `menu name ${menuInfo.menuName}`);
    if (!this.menuNames.has(menuInfo.menuName)) {
      HiLog.warn(this.TAG, 'not registered menu');
      return;
    }
    let handleFunction = this.handlers.get(menuInfo.menuName);
    if (handleFunction) {
      handleFunction(menuInfo);
    } else {
      HiLog.warn(this.TAG, 'no handler');
    }
  }

  private handleFavorite(menuInfo: MenuInfo) {
    let fileList: FileInfo[] = menuInfo.selectedFiles;
    if (menuInfo.selectedFiles.length === 0) {
      fileList = [menuInfo.fileInfo];
    }
    FavoriteDbManager.getInstance().addNewFavoriteList(fileList).then((res) => {
      if (res) {
        UEUtil.reportFileFavorite(DFX.FavoriteOperType.ADD_TO_FAVORITE,
          menuInfo.isLongPress ? DFX.OperateSource.PRESS_MENU : DFX.OperateSource.BOTTOM_MENU,
          fileList.length);
        AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility(
          ResourceUtil.getStringByResource($r('app.string.favorited')));
      }
      EventBus.emit(Constant.EVENTS.FAVORITE_REFRESH);
      EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
    });
  }

  private handleUnFavorite(menuInfo: MenuInfo) {
    let fileList: FileInfo[] = menuInfo.selectedFiles;
    if (menuInfo.selectedFiles.length === 0) {
      fileList = [menuInfo.fileInfo];
    }
    FavoriteDbManager.getInstance()
      .deleteFavoriteFolderList(fileList)
      .then((res) => {
        if (res) {
          UEUtil.reportFileFavorite(DFX.FavoriteOperType.CANCEL_FROM_FAVORITE,
            menuInfo.isLongPress ? DFX.OperateSource.PRESS_MENU : DFX.OperateSource.BOTTOM_MENU,
            fileList.length);
          AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility(
            ResourceUtil.getStringByResource($r('app.string.unfavorable')));
        }
        EventBus.emit(Constant.EVENTS.FAVORITE_REFRESH);
        EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
      })
  }

  private handleSetRingtone(menuInfo: MenuInfo) {
    MenuUtil.setRingtone(menuInfo.fileInfo, () => {
      this.menuActionCallback?.(menuInfo);
    })
  }

  private handleRestore(menuInfo: MenuInfo): void {
    if (!menuInfo) {
      HiLog.warn(this.TAG, 'handleRestore: menuInfo is null');
      return;
    }
    let operateFileList: FileInfo[] = [];
    if (!menuInfo.isLongPress) {
      // 非长按场景直接处理选中文件
      HiLog.info(this.TAG, 'handleRestore: not longPress restore');
      operateFileList = menuInfo.selectedFiles;
    } else {
      let fileInfo: FileInfo = menuInfo.fileInfo;
      if (!fileInfo) {
        HiLog.warn(this.TAG, 'handleRestore: longPress fileInfo is null');
        return;
      }
      if (fileInfo.isChecked) {
        operateFileList = menuInfo.selectedFiles;
      } else {
        HiLog.info(this.TAG, 'handleRestore: longPress restore one');
        operateFileList = [fileInfo];
      }
    }
    UEUtil.reportRestoreFile(DFX.OperateSource.PRESS_MENU, operateFileList.length);
    HiLog.info(this.TAG, 'handleRestore: restore fileCount', operateFileList.length);
    EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, operateFileList, Constant.OPERATION_TYPE.RESTORE);
  }
}