/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import type context from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import { FolderRecord } from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';
import HashMap from '@ohos.util.HashMap';
import type { BusinessError } from '@ohos.base';

const RECORD_MAX_COUNT: number = 50;
const TAG = 'BasePreference';

export abstract class BasePreference {
  public static fileUriArray: HashMap<string, string[]> = new HashMap();
  abstract preferenceInstance?: preferences.Preferences;
  abstract fileName: string;

  abstract loadPreference(context: context.Context, fileName: string);

  /**
   * 异步获取指定key对应的value值
   *
   * @param name preferences名称
   * @param keyName key名称
   * @param defaultValue 默认值
   */
  public async get<T>(keyName: string, defaultValue: preferences.ValueType): Promise<T> {
    if (!keyName) {
      HiLog.warnPrivate(TAG, 'key name is empty', this.fileName);
      return defaultValue as T;
    }
    if (!this.preferenceInstance) {
      HiLog.infoPrivate(TAG, 'preferences is invalid, can not get', this.fileName);
      return defaultValue as T;
    }
    let result = defaultValue;
    try {
      result = await this.preferenceInstance.get(keyName, defaultValue);
    } catch (err) {
      HiLog.errorPrivate(TAG, 'get preferences err: ' + err, this.fileName);
    }
    return result as T;
  }

  /**
   * 同步获取指定key对应的value值
   *
   * @param name preferences名称
   * @param keyName key名称
   * @param defaultValue 默认值
   */
  public getSync<T>(keyName: string, defaultValue: preferences.ValueType): T {
    if (!keyName) {
      HiLog.warnPrivate(TAG, 'key name is empty', this.fileName);
      return defaultValue as T;
    }
    if (!this.preferenceInstance) {
      HiLog.infoPrivate(TAG, 'preferences is invalid, can not get', this.fileName);
      return defaultValue as T;
    }
    let result = defaultValue;
    try {
      result = this.preferenceInstance.getSync(keyName, defaultValue);
    } catch (err) {
      HiLog.errorPrivate(TAG, 'get preferences err: ' + err, this.fileName);
    }
    return result as T;
  }

  /**
   * 获取持久化存储中的所有键值对
   * @returns 键值对构成的对象
   */
  public async getAll(): Promise<Object | undefined> {
    let resultObj: object | undefined;
    try {
      if (!this.preferenceInstance) {
        HiLog.error(TAG, 'getAll fail, cause this.preferenceInstance is undefined');
        return;
      }
      resultObj = await this.preferenceInstance.getAll();
    } catch (err) {
      HiLog.errorPrivate(TAG, 'getAll fail, err: ' + err, this.fileName);
    }
    return resultObj;
  }

  /**
   * get folderRecord from FolderPreference, return undefined if not contain uri
   * @param uri folder uri
   */
  public async getRecord(uri: string): Promise<FolderRecord | null> {
    HiLog.infoPrivate(TAG, 'getRecord : ', uri);
    if (!uri) {
      HiLog.warnPrivate(TAG, 'can not putRecord, uri is invalid', this.fileName);
      return null;
    }
    if (!this.preferenceInstance) {
      HiLog.infoPrivate(TAG, 'preferences is invalid, can not get', this.fileName);
      return null;
    }
    let folderRecord: FolderRecord | null = null;
    let recordStr = await this.preferenceInstance.get(uri, '');
    if (recordStr === '') {
      HiLog.infoPrivate(TAG, 'get no record, return undefined', this.fileName);
    } else {
      folderRecord = JSON.parse(recordStr.toString());
    }
    return folderRecord;
  }

  /**
   * 异步存储值
   *
   * @param keyName key字段名称
   * @param value 存储值
   */
  async put(keyName: string, value: preferences.ValueType): Promise<void> {
    if (!keyName) {
      HiLog.warnPrivate(TAG, 'key name is empty', this.fileName);
      return;
    }
    try {
      if (!this.preferenceInstance) {
        HiLog.error(TAG, 'put fail, cause this.preferenceInstance is undefined');
        return;
      }
      await this.preferenceInstance.put(keyName, value);
      this.preferenceInstance.flush();
    } catch (err) {
      HiLog.errorPrivate(TAG, 'put preferences err: ' + err, this.fileName);
    }
  }

  /**
   * 同步存储值
   * @param keyName key字段名称
   * @param value 存储值
   */
  putSync(keyName: string, value: preferences.ValueType): void {
    if (!keyName) {
      HiLog.warnPrivate(TAG, 'key name is empty', this.fileName);
      return;
    }
    try {
      if (!this.preferenceInstance) {
        HiLog.error(TAG, 'put fail, cause this.preferenceInstance is undefined');
        return;
      }
      this.preferenceInstance.putSync(keyName, value);
      this.preferenceInstance.flush();
    } catch (err) {
      HiLog.errorPrivate(TAG, 'put preferences err: ' + err, this.fileName);
    }
  }

  /**
   * 更新、插入Map中的数据
   * @param map
   */
  putFromMap(map: Map<string, preferences.ValueType>) {
    if (!map || map.size === 0) {
      HiLog.warnPrivate(TAG, 'map is empty', this.fileName);
      return;
    }
    try {
      if (!this.preferenceInstance) {
        HiLog.error(TAG, 'putMap fail, cause this.preferenceInstance is undefined');
        return;
      }
      for (const key of map.keys()) {
        this.preferenceInstance.putSync(key, map.get(key));
      }
      this.preferenceInstance.flush();
    } catch (err) {
      HiLog.errorPrivate(TAG, 'putMap preferences err: ' + err, this.fileName);
    }
  }

  /**
   * 删除指定字段
   * @param keyName key名称
   */
  async delete(keyName: string): Promise<void> {
    if ((!keyName) || (!this.preferenceInstance)) {
      HiLog.warnPrivate(TAG, 'key name or this.preferenceInstance is empty or undefined!', this.fileName);
      return;
    }

    try {
      await this.preferenceInstance.delete(keyName);
      this.preferenceInstance.flush();
      return;
    } catch (err) {
      HiLog.errorPrivate(TAG, 'delete key err: ' + err, this.fileName);
      return;
    }
  }

  /**
   * 批量删除指定字段
   * @param keyList key名称
   */
  async batchDelete(keyList: string[]): Promise<void> {
    if ((!keyList) || (keyList.length === 0) || (!this.preferenceInstance)) {
      HiLog.warnPrivate(TAG, 'key name or this.preferenceInstance is empty or undefined!', this.fileName);
      return;
    }

    try {
      for (let key of keyList) {
        if (key) {
          await this.preferenceInstance.delete(key);
        }
      }
      this.preferenceInstance.flush();
      return;
    } catch (err) {
      HiLog.errorPrivate(TAG, `delete key failed, error.code: ${err?.code}, error.message: ${err?.message}, fileName: `,
        this.fileName);
      return;
    }
  }

   /**
   * delete uri and folderRecord from uriArray and FolderPreference
   * @param uri folder uri
   */
  public deleteRecord(uri: string): void {
    HiLog.infoPrivate(TAG, 'deleteRecord : ', uri);
    if (!uri) {
      HiLog.warnPrivate(TAG, 'can not deleteRecord, uri is invalid', this.fileName);
      return;
    }
    if (!this.preferenceInstance) {
      HiLog.infoPrivate(TAG, 'preferences is invalid, can not delete', this.fileName);
      return;
    }
    this.preferenceInstance.delete(uri)
      .then(() => {
        this.deleteUri(uri);
        this.flushRecord();
      })
      .catch((err: BusinessError) => {
        HiLog.warnPrivate(TAG, 'delete record err : ' + err, this.fileName);
      });
  }

  /**
   * 判断指定的preferences中是否存在对应的key
   * @param keyName key名称
   */
  async has(keyName: string): Promise<boolean> {
    if (!keyName) {
      HiLog.warnPrivate(TAG, 'key name is empty', this.fileName);
      return false;
    }
    if (!this.preferenceInstance) {
      HiLog.error(TAG, 'has fail, cause this.preferenceInstance is undefined');
      return false;
    }
    try {
      return await this.preferenceInstance.has(keyName);
    } catch (err) {
      HiLog.errorPrivate(TAG, 'has key err: ' + err, this.fileName);
    }
    return false;
  }

  /**
   * 清除指定的preferences文件
   *
   * @param name preferences名称
   */
  async clear(): Promise<boolean> {
    if (!this.preferenceInstance) {
      HiLog.error(TAG, 'clear fail, cause this.preferenceInstance is undefined');
      return false;
    }
    let result = false;
    try {
      await this.preferenceInstance.clear();
      await this.preferenceInstance.flush();
      result = true;
    } catch (err) {
      HiLog.errorPrivate(TAG, 'clear preferences err: ' + err, this.fileName);
    }
    return result;
  }

  public loadPreferenceSync(context: context.Context, fileName: string): void {
    let options: preferences.Options = { name: fileName };
    try {
      this.preferenceInstance = preferences.getPreferencesSync(context, options);
    } catch (err) {
      HiLog.warnPrivate(TAG, 'load preferences sync err :' + err, this.fileName);
    }
    this.fileName = fileName;
    return;
  }

  /**
   * 删除指定的preferences文件
   *
   * @param name preferences名称
   */
  public async deletePreference(context: context.Context): Promise<void> {
    if (!this.fileName) {
      HiLog.error(TAG, 'delete preference fail, cause this.fileName is undefined');
      return;
    }

    try {
      await preferences.deletePreferences(context, this.fileName);
    } catch (err) {
      HiLog.warnPrivate(TAG, 'delete preferences sync err :' + err, this.fileName);
    }
  }

  public updateCache(context: context.Context): void {
    if (!this.fileName) {
      HiLog.error(TAG, 'removeCache preference fail, cause this.fileName is undefined');
      return;
    }
    if (!context) {
      HiLog.error(TAG, 'removeCache preference fail, cause context is undefined');
      return;
    }
    try {
      preferences.removePreferencesFromCacheSync(context, this.fileName);
      HiLog.info(TAG, 'remove cache success');
    } catch (err) {
      HiLog.warnPrivate(TAG, 'removeCache preferences sync err :' + err, this.fileName);
    }
    // 旧对象在清理缓存后还是可以继续使用，还是旧的数据，所以清除缓存后需要重新获取对象
    let options: preferences.Options = { name: this.fileName };
    try {
      this.preferenceInstance = preferences.getPreferencesSync(context, options);
    } catch (err) {
      HiLog.warnPrivate(TAG, 'load preferences sync after removeCache err :' + err, this.fileName);
    }
  }

  /**
   * write uri and folderRecord to FolderPreference
   * @param err
   */
  private flushRecord(): void {
    if (!this.preferenceInstance) {
      HiLog.error(TAG, 'flushRecord fail, cause this.preferenceInstance is undefined');
      return;
    }
    this.preferenceInstance.flush()
      .then(() => {
        HiLog.infoPrivate(TAG, 'flush record successfully', this.fileName);
      })
      .catch((err: BusinessError) => {
        HiLog.warnPrivate(TAG, 'flush record err : ' + err, this.fileName);
      });
  }

  /**
   * process uriArray
   * @param uri folder uri
   */
  private deleteUri(uri: string): void {
    HiLog.infoPrivate(TAG, 'deleteUri : ', uri);
    let uriArray = BasePreference.fileUriArray.get(this.fileName);
    if (uriArray) {
      for (let i = 0; i < uriArray.length; i++) {
        if (uriArray[i] === uri) {
          uriArray.splice(i, 1);
          HiLog.infoPrivate(TAG, 'delete uri from FilePickerUriArray successfully', this.fileName);
          break;
        }
      }
    } else {
      HiLog.infoPrivate(TAG, 'FilePickerUriArray is invalid, can not delete', this.fileName);
    }
  }
}