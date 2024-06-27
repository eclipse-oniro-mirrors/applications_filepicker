/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { ability, wantConstant } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { DownloadDialog } from './component/dialog/DownloadDialog';
import { StartModeOptions } from '../base/model/StartModeOptions';
import { FilePickerUtil } from '../base/utils/FilePickerUtil';
import Logger from '../base/log/Logger';
import { VirtualUri } from '../base/constants/FolderRecord';
import { FsUtil } from '../base/utils/FsUtil';
import { FileUtil } from '../base/utils/FileUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import uriPermissionManager from '@ohos.application.uriPermissionManager';
import AbilityCommonUtil from '../base/utils/AbilityCommonUtil';


const TAG = 'DownloadAuth';
const DOWNLOAD_PATH = '/storage/Users/currentUser/Download';
let storage = LocalStorage.getShared();

@Component
@Entry(storage)
struct DownloadAuth {
  private downloadNewUri: string = '';
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private session: UIExtensionContentSession = this.startModeOptions.session;
  // 存储当前从bms查询到的所有应用的bundle信息
  public bundleArray: Array<bundleManager.BundleInfo> = [];
  private appName: string | undefined = storage.get<string>('appName');
  private appIcon: string | undefined = storage.get<string>('appIcon');
  private confirm: Function = () => {
  };
  // 弹窗关联取消
  private cancel: Function = () => {
  };

  aboutToAppear(): void {
    Logger.i(TAG, 'DownloadAuth aboutToAppear');
  }

  onPageShow() {
    Logger.i(TAG, 'DownloadAuth onPageShow appName: ' + this.appName + ', appIcon: ' + this.appIcon);
    this.downloadDialogOpen();
  }

  downloadDialogOpen(): void {
    this.confirm = async () => {
      this.downloadDialogConfirm();
      this.externalDownloadDialog.close();
    };
    this.cancel = () => {
      this.externalDownloadDialog.close();
      if (this.session != undefined) {
        this.session.terminateSelf();
      }
    };
    this.externalDownloadDialog.open();
  }

  async downloadDialogConfirm(): Promise<void> {
    const bundleName: string = this.startModeOptions.callerBundleName;
    Logger.i(TAG, 'Download Dialog confirm.');
    this.downloadNewUri = VirtualUri.DOWNLOAD + '/' + bundleName;
    let isExist: boolean = FsUtil.accessSync(DOWNLOAD_PATH + '/' + bundleName);
    if (!isExist) {
      this.downloadNewUri = FileUtil.createFolderByFs(VirtualUri.DOWNLOAD, bundleName);
    }
    Logger.i(TAG, 'Download Dialog return uri is: ' + this.downloadNewUri);
    AbilityCommonUtil.grantUriPermission([this.downloadNewUri], bundleName);
    this.externalDownloadDialog.close();
    if (this.session === undefined) {
      Logger.i(TAG, `this.session is undefined`)
      return;
    }
    Logger.i(TAG, 'Download Dialog exist close.');
    let abilityResult: ability.AbilityResult = {
      resultCode: (this.downloadNewUri === undefined) ? -1 : 0,
      want: {
        parameters: {
          'downloadNewUri': this.downloadNewUri
        }
      }
    };
    this.session.terminateSelfWithResult(abilityResult, (error) => {
      Logger.i(TAG, 'terminateSelfWithResult is called = ' + error?.code);
    });
  }

  build() {
  }

  //外部调用下载弹窗
  externalDownloadDialog: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      appName: this.appName,
      appIcon: this.appIcon,
      confirm: this.confirm,
      cancel: this.cancel
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center, // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })
}