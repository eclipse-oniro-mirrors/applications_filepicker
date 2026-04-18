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
import { expect, MockKit } from '@ohos/hypium';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import { FsUtil, HiLog } from '@ohos/common';
import fs from '@ohos.file.fs';

const delegator = AbilityDelegatorRegistry.getAbilityDelegator();
const bundleName = AbilityDelegatorRegistry.getArguments().bundleName;

export class TestUtil {
  public static readonly IMAGE_URL = 'file://docs/storage/Users/currentUser/Picturesimage';
  public static readonly PICTURE_TYPE_URL = 'file://docs/storage/Users/currentUser/Pictures/';
  public static readonly VIDEO_URL = 'file://docs/storage/Users/currentUser/Moviesimage';
  public static readonly VIDEO_FILE_URL = 'file://docs/storage/Users/currentUser/Movies/';
  public static readonly DESKTOP_URL = 'file://docs/storage/Users/currentUser/Desktop/';
  public static readonly DESKTOP_URL_NO = 'file://docs/storage/Users/currentUser/Desktop';
  public static readonly DESKTOP_URL_IMAGE = 'file://docs/storage/Users/currentUser/Desktopimage';
  public static readonly DOWNLOAD_URL = 'file://docs/storage/Users/currentUser/Download/';
  public static readonly MYPC_URL = 'file://docs/storage/Users/currentUser/';
  public static readonly DOCUMENTS_URL = 'file://docs/storage/Users/currentUser/Documents/';
  public static readonly DOCUMENTS_URL_IMAGE = 'file://docs/storage/Users/currentUser/Documentsimage';
  public static readonly NEWFLODER = '/新建文件夹';
  public static readonly NEWFLODERSTRING = '新建文件夹';
  public static readonly WAIT_TIME_MS = 100;
  public static readonly WAIT_TIME_MS_TEN = 1000;
  public static readonly WAIT_TIME_MS_TEN_FIVE = 5000;
  public static readonly TEST_FOLDER_URI = 'file://docs/storage/Users/currentUser/TestFolder';
  public static readonly TEST_FOLDER_PATH = 'storage/Users/currentUser/TestFolder';

  static async clickToMainPage(): Promise<void> {
    let cmd = 'aa start -b ' + bundleName + ' -a MainAbility';
    await delegator.executeShellCommand(cmd)
      .then((data) => {
        console.info('succeed to executeShellCommand start Ability');
      }).catch((err: BusinessError) => {
        expect(err).assertEqual(null);
      })
  }

  static async checkAddressSecondPart(driver: Driver, address: string): Promise<boolean> {
    let pathPart = await driver.findComponent(ON.id('FileManager_FirstSegComp_1_TEXT'));
    let text = await pathPart.getText();
    return address === text;
  }

  static async keepWakeUp(): Promise<void> {
    await delegator.executeShellCommand('power-shell wakeup');
    await delegator.executeShellCommand('power-shell setmode 602');
  }

  static async restorePowerMode(): Promise<void> {
    await delegator.executeShellCommand('power-shell setmode 600');
  }

  static async openFilePicker(): Promise<void> {
    let cmd = 'aa start -b ' + bundleName + ' -a FilePickerAbility';
    await delegator.executeShellCommand(cmd);
  }

  // 测试私有函数
  static getPrivateFunction(obj: object, functionName: string): Function | null {
    const func: Function = obj[functionName];
    if (func) {
      return func.bind(obj);
    } else {
      return null;
    }
  }

  // 获取私有属性
  static getPrivateAttribute<T>(obj: object, attributeName: string): T {
    return obj[attributeName];
  }

  // 设置私有属性
  static setPrivateAttribute<T>(obj: object, attributeName: string, value: T) {
    obj[attributeName] = value;
  }

  // 返回私有方法mock对象
  static getPrivateMockFunction(mocker: MockKit, obj: object, functionName: string): Function {
    return mocker.mockFunc(obj, obj[functionName]);
  }

  // 清理mock对象（objectUtil，无发直接clear）
  static clearMockObject(mocker: MockKit, obj: object): void {
    mocker.clear(obj);
  }

  static createTestFileOrFolder(fileNameList: string[], createFolder: boolean) {
    try {
      if (!fs.accessSync(TestUtil.TEST_FOLDER_PATH)) {
        fs.mkdirSync(TestUtil.TEST_FOLDER_PATH);
      }
      fileNameList.forEach((item: string) => {
        let filePath: string = TestUtil.TEST_FOLDER_PATH + '/' + item;
        if (createFolder) {
          fs.mkdirSync(filePath);
        } else {
          let file = FsUtil.openSync(filePath, fs.OpenMode.CREATE) as fs.File;
          FsUtil.closeSync(file);
        }
      })

    } catch (e) {
      HiLog.info('createTestFileOrFolder', `createTestFileOrFolder fail: ${JSON.stringify(e)}`)
    }
  }

  static deleteTestFileOrFolder() {
    try {
      if (!fs.accessSync(TestUtil.TEST_FOLDER_PATH)) {
        fs.rmdirSync(TestUtil.TEST_FOLDER_PATH);
      }
    } catch (e) {
      HiLog.info('deleteTestFileOrFolder', `deleteTestFileOrFolder fail: ${JSON.stringify(e)}`)
    }
  }
}
