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

import dataSharePredicates from '@ohos.data.dataSharePredicates';
import type { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket';
import rdb from '@ohos.data.relationalStore';
import { FavoriteModel } from '../model/FavoriteModel';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';
import { TimeUtil } from '../utils/TimeUtil';
import { ArrayUtil } from '../utils/ArrayUtil';
import { FavoriteModelUtil } from './FavoriteModelUtil';
import { Constant, DataSourceDeviceType } from '../const/Constant';
import { StringUtil } from '../utils/StringUtil';
import type { DiskInfo } from '../externel/DiskInfo';
import { StorageDeviceManager } from '../externel/StorageDeviceManager';
import { Rdb } from '../database/Rdb';
import { ExternalStorageUtil } from '../externel/ExternalStorageUtil';
import { FileInfo } from '../fileoperate/FileInfo';
import { FileUtil } from '../fileoperate/FileUtil';
import { FavoriteDataConst, FavoriteDataEnum } from '../const/FavoriteDataConst';
import { RecentDataEnum, RecentDataConst } from '../const/RecentDataConst';

const TAG: string = 'FavDbMag';

/**
 * 收藏夹数据库配置
 */
const STORE_CONFIG: rdb.StoreConfig = {
  name: FavoriteDataEnum.DATABASE_NAME,
  securityLevel: rdb.SecurityLevel.S2,
  haMode: rdb.HAMode.MAIN_REPLICA, //配置为双写备份
  allowRebuild: true
};

export class FavoriteDbManager {
  /**
   * 实例
   */
  private static instance: FavoriteDbManager;
  private _favoriteCache: FavoriteModel[] = [];

  protected get favoriteCache(): FavoriteModel[] {
    return this._favoriteCache;
  }

  protected set favoriteCache(list: FavoriteModel[]) {
    this._favoriteCache = list;
  }

  private MAX_INDEX: number = 0;
  private MAX_LENGTH: number = 100; // pc侧最多收藏100个目录

  private _table = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);

  protected get table(): Rdb {
    return this._table;
  }

  private _tableRecent =
    new Rdb(RecentDataEnum.TABLE_NAME, RecentDataConst.SQL_CREATE_TABLE, RecentDataConst.RECENT_COLUMNS);

  protected get tableRecent(): Rdb {
    return this._tableRecent;
  }

  private _rdbCreateSuccess: boolean = false;

  protected get rdbCreateSuccess(): boolean {
    return this._rdbCreateSuccess;
  }

  private set rdbCreateSuccess(flag: boolean) {
    this._rdbCreateSuccess = flag;
  }

  private _rdbCreateSuccessRecent: boolean = false;

  protected get rdbCreateSuccessRecent(): boolean {
    return this._rdbCreateSuccessRecent;
  }

  private set rdbCreateSuccessRecent(flag: boolean) {
    this._rdbCreateSuccessRecent = flag;
  }

  public static getInstance(): FavoriteDbManager {
    if (ObjectUtil.isNullOrUndefined(FavoriteDbManager.instance)) {
      FavoriteDbManager.instance = new FavoriteDbManager();
    }
    return FavoriteDbManager.instance;
  }

  /**
   * 检查fileList中的资源是否存在recent表中，是表明30天内删除过这个资源的访问记录，不显示
   * @param fileList
   * @returns
   */
  public async queryRecent(galleryUris: string[]): Promise<boolean[]> {
    HiLog.info(TAG, 'queryRecent start');
    let res: boolean[] = [];
    if (ArrayUtil.isEmpty(galleryUris)) {
      HiLog.warn(TAG, 'queryRecent list  is empty');
      return res;
    }
    await this.initRdbStore();
    res = await this.tableRecent.queryRecent(galleryUris);
    HiLog.info(TAG, 'queryRecent end:');
    return res;
  }

  /**
   * 老化最近页面删除过访问记录的数据，即在recent删除插入超过30天的数据
   * @returns
   */
  public async recentDataAging(): Promise<void> {
    HiLog.info(TAG, 'recentDataAging start');
    await this.initRdbStore();
    let res = await this.tableRecent.recentDataAging()
    // 获取最近页删除的数据的数量记录下来
    let cnt = await this.tableRecent.getRecentNumber();
    AppStorage.setOrCreate('recentDelNum', cnt);
    HiLog.info(TAG, 'recentDataAging end:' + cnt);
  }

  public async insertRecentDelete(fileList: FileInfo[]): Promise<number> {
    HiLog.info(TAG, 'insertRecentDelete start');
    let rows = 0;
    await this.initRdbStore();
    rows = await this.tableRecent.insertRecent(fileList);
    HiLog.info(TAG, 'insertRecentDelete insert end:' + rows);
    // 获取最近页删除的数据的数量
    let cnt = await this.tableRecent.getRecentNumber();
    AppStorage.setOrCreate('recentDelNum', cnt);
    HiLog.info(TAG, 'insertRecentDelete getRecentNumber end:' + cnt);
    return rows
  }

  /**
   * 新增收藏
   *
   * @param fileDataList 收藏文件列表
   * @param deviceType 收藏文件所在的设备类型
   * @returns 返回添加是否成功
   */
  public async addNewFavoriteList(fileDataList: FileInfo[],
    deviceType: DataSourceDeviceType = DataSourceDeviceType.DEVICE_INTERNAL): Promise<boolean> {
    if (ArrayUtil.isEmpty(fileDataList)) {
      HiLog.info(TAG, 'addNewFavoriteList: list is empty');
      return false;
    }

    let favoriteList =
      FavoriteModelUtil.createFavoriteListByFileDataList(fileDataList, deviceType, this.MAX_INDEX++, false);
    let insertCount = await this.insertToDB(favoriteList);
    HiLog.info(TAG, 'addNewFavoriteList:favoriteList = ' + favoriteList.length + ' ; insertCount = ' + insertCount +
      ' ; maxSorIndex = ' + this.MAX_INDEX);
    if (insertCount > 0) {
      this.addFavoriteCacheList(favoriteList);
      return true;
    } else {
      return false;
    }
  }

  /**
   * 根据选择的文件列表，过滤出相关收藏数据
   *
   * @param fileList  文件列表
   * @param isTrashFile 是否是最近删除数据
   * @returns 返回收藏数据
   */
  public getFavoriteFileList(fileList: FileInfo[], isTrashFile: boolean = false): FavoriteModel[] {
    let favoriteList: FavoriteModel[] = [];
    if (!this.checkFavoriteParams(fileList)) {
      return favoriteList;
    }

    let len = fileList.length;
    for (let i = 0; i < len; i++) {
      let fileData = fileList[i];
      if (!fileData.isFolder) {
        continue;
      }

      let path = isTrashFile ? fileData.srcPath : fileData.relativePath;
      for (let j = 0; j < this.favoriteCache.length; j++) {
        let favorite = this.favoriteCache[j];
        if (favorite.path === path || favorite.path.startsWith(FileUtil.getPathWithFileSplit(path))) {
          favoriteList.push(favorite);
        }
      }
    }
    HiLog.info(TAG, 'getFavoriteFileList:favoriteListSize = ' + favoriteList.length);
    return favoriteList;
  }

  /**
   * 查询所有满足条件的收藏数据
   *
   * @param deviceList 外挂设备列表
   * @returns 返回满足条件的收藏数据
   */
  public async getAllFavoriteList(deviceList: DiskInfo[]): Promise<Array<FavoriteModel>> {
    HiLog.info(TAG, 'getAllFavoriteList enter');
    this.favoriteCache = await this.queryDataFromDB(deviceList);
    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.info(TAG, 'favoriteCache is empty');
      return this.favoriteCache;
    }
    return this.favoriteCache.filter((item, index, array) => {
      let deviceType = item.deviceType;
      let itemPath = item.path;
      if (item.recycled) {
        return false;
      }
      if (deviceType === DataSourceDeviceType.DEVICE_INTERNAL) {
        return true;
      } else if (deviceType === DataSourceDeviceType.DEVICE_EXTERNAL) {
        if (!ArrayUtil.isEmpty(deviceList)) {
          let index = deviceList.findIndex((disk: DiskInfo) => {
            let diskPath = disk.relativePath;
            return (diskPath === itemPath || itemPath.startsWith(FileUtil.getPathWithFileSplit(diskPath)));
          });
          return index !== -1;
        }
      }
      return false;
    });
  }

  /**
   * 保存当前编辑状态，如果没有发生拖动，建议不要调用该接口
   *
   * @param favoriteList 需要更新的收藏数据列表
   * @returns 返回保存结果
   */
  public async saveFavoriteCache(favoriteList: FavoriteModel[]): Promise<boolean> {
    if (ArrayUtil.isEmpty(favoriteList)) {
      return false;
    }
    let tempList = favoriteList.reverse();
    let needClearIdList: number[] = [];
    for (let i = 0; i < tempList.length; i++) {
      this.MAX_INDEX++;
      let tempFile = tempList[i];
      tempFile.sortIndex = this.MAX_INDEX;
      needClearIdList.push(tempFile.id);
    }
    let insertCount = await this.insertToDB(tempList);
    if (insertCount > 0) {
      await this.deleteDataByValueList(needClearIdList);
      return true;
    }
    return false;
  }

  /**
   * 取消收藏
   *
   * @param favorite 收藏对象
   * @returns 返回删除结果
   */
  public async deleteFavoriteFolder(favorite: FavoriteModel): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(favorite)) {
      HiLog.error(TAG, 'deleteFavoriteFolder error favorite is null');
      return false;
    }
    if (StringUtil.isEmpty(favorite.path)) {
      HiLog.error(TAG, 'deleteFavoriteFolder error path is empty');
      return false;
    }
    let deletePathList: string[] = [];
    let count = 0;
    deletePathList.push(favorite.path);
    count = await this.deleteLocalDataByValueList(deletePathList, FavoriteDataEnum.COLUMN_PATH,
      Constant.FILE_RECYCLED.NORMAL);
    return this.handleResult(count);
  }

  /**
   * 批量取消收藏
   *
   * @param fileDataList 收藏列表
   * @returns 返回删除结果
   */
  public async deleteFavoriteFolderList(fileDataList: FileInfo[]): Promise<boolean> {
    if (!this.checkDeleteParams(fileDataList)) {
      return false;
    }

    let count = 0;
    let deleteLocalPathList: string[] = [];
    for (let i = 0; i < fileDataList.length; i++) {
      let path = fileDataList[i].relativePath;
      let index = this.favoriteCache.findIndex((item: FavoriteModel) => {
        if (item.recycled) {
          return false;
        }
        return item.path === path;
      });
      if (index !== -1) {
        let favorite = this.favoriteCache[index];
        deleteLocalPathList.push(favorite.path);
      }
      count += await this.deleteLocalDataByValueList(deleteLocalPathList, FavoriteDataEnum.COLUMN_PATH,
        Constant.FILE_RECYCLED.NORMAL);
    }
    return this.handleResult(count);
  }

  /**
   * 重命名更新收藏数据库信息
   *

   * @param oldPath 旧的文件路径
   * @param newPath 新的文件路径
   * @param newFileName 新的文件名称
   * @returns 返回是否更新成功
   */
  public async updateFileInfoByReName(oldPath: string, newPath: string, newFileName: string): Promise<boolean> {
    if (!this.checkReNameParams(oldPath, newPath, newFileName)) {
      return false;
    }

    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.warn(TAG, 'favoriteCache is empty');
      return false;
    }
    let needClearValueList: string[] = [];
    let favoriteList: FavoriteModel[] = [];
    let index = this.favoriteCache.findIndex(item => item.path === oldPath && !item.recycled);
    if (index !== -1) {
      let favorite = this.favoriteCache[index];
      needClearValueList.push(favorite.path);
      favorite.path = newPath;
      favorite.name = newFileName;
      favoriteList.push(favorite);
    }

    let subOldPath = FileUtil.getPathWithFileSplit(oldPath);
    let subNewPath = FileUtil.getPathWithFileSplit(newPath);

    for (let i = 0; i < this.favoriteCache.length; i++) {
      let subFavorite = this.favoriteCache[i];
      if (subFavorite.path.startsWith(subOldPath) && (!subFavorite.recycled)) {
        let oldSubPath = subFavorite.path;
        let newSubPath = oldSubPath.replace(subOldPath, subNewPath);
        needClearValueList.push(oldSubPath);
        subFavorite.path = newSubPath
        favoriteList.push(subFavorite);
      }
    }
    let updateCount = await this.insertToDB(favoriteList);
    await this.deleteLocalDataByValueList(needClearValueList, FavoriteDataEnum.COLUMN_PATH,
      Constant.FILE_RECYCLED.NORMAL);
    HiLog.info(TAG, `updateFileInfoByReName end, data : ${updateCount}`);
    return this.handleResult(updateCount);
  }

  /**
   * 新建文件夹更新收藏数据库信息
   *
   * @param uri 新建的目录uri
   * @returns 返回是否更新成功
   */
  public async updateFileInfoByCreateFolder(uri: string): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(uri) || StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'uri is Undefined');
      return false;
    }

    let path = uri;
    if (FileUtil.isUriPath(uri)) {
      path = FileUtil.getPathFromUri(uri);
    }

    let storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
    if (!FileUtil.isInternalPath(path, storageDeviceList)) {
      return false;
    }

    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.warn(TAG, 'favoriteCache is empty');
      return false;
    }

    let index = this.favoriteCache.findIndex(item => item.path === path && item.recycled);
    let updateCount = 0;
    if (index !== -1) {
      let favorite = this.favoriteCache[index];
      favorite.sortIndex = this.MAX_INDEX++;
      favorite.recycled = false;
      updateCount = await this.updateFavoriteDataByPath(favorite, path);
    }

    HiLog.info(TAG, `updateFileInfoByCreateFolder end, data : ${updateCount}`);
    return this.handleResult(updateCount);
  }

  /**
   * 最近删除清除的数据需要在收藏数据库里清除
   *
   * @param deleteIdList 要清除的收藏数据的ID
   * @returns 返回数据库更新结果
   */
  public async clearHardDeleteFileByPath(deleteIdList: Array<number>): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(deleteIdList) || ArrayUtil.isEmpty(deleteIdList)) {
      HiLog.warn(TAG, 'clearHardDeleteFileByPath: deleteIdList is null');
      return false;
    }

    let deleteCount = await this.deleteDataByValueList(deleteIdList);

    HiLog.info(TAG, `clearHardDeleteFileByPath end, data : ${deleteCount}`);
    return this.handleResult(deleteCount);
  }

  /**
   * 清除脏数据，即已经被回收站清除的数据
   *
   * @param folderList 回收站文件夹
   * @returns
   */
  public async clearDirtyDataByTrashList(folderList: FileInfo[]): Promise<number> {
    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      return -1;
    }

    if (ObjectUtil.isNullOrUndefined(folderList) || ArrayUtil.isEmpty(folderList)) {
      HiLog.warn(TAG, 'clearDirtyDataByTrashList: folderList is null');
      this.deleteLocalRecycledData();
      return -1;
    }

    let pathList: string[] = [];
    for (let i = 0; i < this.favoriteCache.length; i++) {
      let favorite = this.favoriteCache[i];
      if (!favorite.recycled) {
        continue;
      }
      let path = favorite.path;
      let index = this.getPathAndSubPathIndex(folderList, path);
      if (index !== -1) {
        continue;
      }
      pathList.push(favorite.path);
    }
    return this.deleteLocalDataByValueList(pathList, FavoriteDataEnum.COLUMN_PATH, Constant.FILE_RECYCLED.UNKNOWN);
  }

  /**
   * 软删除收藏相关文件数据更新
   *
   * @param favoriteList 恢复的文件
   * @returns 返回数据库更新结果
   */
  public async updateFileInfoBySoftDelete(favoriteList: FavoriteModel[]): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(favoriteList) || ArrayUtil.isEmpty(favoriteList)) {
      HiLog.warn(TAG, 'updateFileInfoByRestore is empty');
      return false;
    }

    let needClearIdList: number[] = [];
    for (let i = 0; i < favoriteList.length; i++) {
      let tempFile = favoriteList[i];
      tempFile.recycled = true;
      needClearIdList.push(tempFile.id);
    }
    let updateCount = await this.insertToDB(favoriteList);
    await this.deleteDataByValueList(needClearIdList);
    HiLog.info(TAG, `updateFileInfoBySoftDelete end, data : ${updateCount}`);
    return this.handleResult(updateCount);
  }

  /**
   * 移动后更新收藏相关文件数据
   *
   * @param favoriteList 恢复的文件
   * @param deleteLocalPathList 需要本地删除的数据路径列表
   * @returns 返回数据库更新结果
   */
  public async updateFileInfoByMove(
    favoriteList: FavoriteModel[],
    deleteLocalPathList: string[]): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(favoriteList) || ArrayUtil.isEmpty(favoriteList)) {
      HiLog.warn(TAG, 'updateFileInfoByMove is empty');
      return false;
    }

    let updateCount = await this.insertToDB(favoriteList);
    await this.deleteLocalDataByValueList(deleteLocalPathList, FavoriteDataEnum.COLUMN_PATH,
      Constant.FILE_RECYCLED.NORMAL);
    HiLog.info(TAG, `updateFileInfoByMove end, data : ${updateCount}`);
    return this.handleResult(updateCount);
  }

  /**
   * 最近删除恢复的数据需要在收藏数据库里更新
   *
   * @param favoriteList 恢复的文件
   * @returns 返回数据库更新结果
   */
  public async updateFileInfoByRestore(favoriteList: FavoriteModel[]): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(favoriteList) || ArrayUtil.isEmpty(favoriteList)) {
      HiLog.warn(TAG, 'updateFileInfoByRestore is empty');
      return false;
    }

    this.favoriteCache = await this.queryDataFromDB();

    let tempList = favoriteList.reverse();
    let needClearIdList: number[] = [];
    for (let i = 0; i < tempList.length; i++) {
      this.MAX_INDEX++;
      let tempFile = tempList[i];
      tempFile.sortIndex = this.MAX_INDEX;
      needClearIdList.push(tempFile.id);
    }
    let insertCount = await this.insertToDB(tempList);
    await this.deleteDataByValueList(needClearIdList);
    HiLog.info(TAG, `updateFileInfoByRestore end, data : ${insertCount}`);
    return this.handleResult(insertCount);
  }

  /**
   * 文件是否已经收藏
   *
   * @param fileData  判断的文件
   * @returns true：已经收藏
   */
  public isFavorite(fileData: FileInfo): boolean {
    if (ObjectUtil.isNullOrUndefined(fileData) || ObjectUtil.isNullOrUndefined(this.favoriteCache) ||
    ArrayUtil.isEmpty(this.favoriteCache)) {
      return false;
    }
    let index = this.favoriteCache.findIndex((item: FavoriteModel) => {
      if (item.recycled) {
        return false;
      }
      if (item.path !== fileData.relativePath) {
        return false;
      }
      return true;
    });
    return index !== -1;
  }

  /**
   * 直接从数据库查询出所有收藏数据
   *
   * @param deviceList 当前设备列表，用于清理已经不挂载的设备
   * @returns 返回收藏数据
   */
  public async queryDataFromDB(deviceList: Array<DiskInfo> = []): Promise<Array<FavoriteModel>> {
    HiLog.info(TAG, 'queryDataFromDB start');
    if (this.table.isRdbStoreNotExist()) {
      await this.table.getRdbStore(STORE_CONFIG);
    }
    let favoriteList: FavoriteModel[] = [];
    let resultSet: rdb.ResultSet | undefined;
    try {
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.orderByDesc(FavoriteDataEnum.COLUMN_SORT_INDEX)
        .orderByDesc(FavoriteDataEnum.COLUMN_SET_TIME);

      resultSet = await this.table.queryTableData(predicates);
      if (resultSet) {
        let rowCount = resultSet.rowCount;
        HiLog.info(TAG, 'queryDataFromDB: rowCount: ' + rowCount);
        resultSet.goToFirstRow();
        let recordPathList = [];
        // 清除重复的脏数据
        let needClearIdList = [];
        let maxIndex = 0;
        for (let i = 0; i < rowCount; i++) {
          let favoriteModel: FavoriteModel = this.transferFavoriteModel(resultSet);
          if (maxIndex < favoriteModel.sortIndex) {
            maxIndex = favoriteModel.sortIndex;
          }
          await this.filterData(favoriteModel, deviceList, favoriteList, recordPathList, needClearIdList);
          resultSet.goToNextRow();
        }
        if (this.MAX_INDEX < maxIndex) {
          this.MAX_INDEX = maxIndex;
        }
        await this.deleteDataByValueList(needClearIdList);
      } else {
        HiLog.warn(TAG, 'queryDataFromDB: resultSet is undefined!');
      }
    } catch (error) {
      HiLog.error(TAG, `queryDataFromDB error: ${error?.message}`);
    } finally {
      if (resultSet) {
        try {
          resultSet.close();
          HiLog.info(TAG, 'ResultSet has been closed.');
        } catch (e) {
          HiLog.error(TAG, `resultSet close error: ${e?.message}`);
        }
      }
    }
    HiLog.info(TAG, 'queryDataFromDB end;' + favoriteList.length);
    return favoriteList;
  }

  /**
   * 直接从数据库查询出所有收藏数据 (PC用)
   * @returns FavoritesFolderArray
   */
  public async queryFavoriteFolderDataFromDB(): Promise<FavoriteModel[]> {
    HiLog.info(TAG, 'queryFavoriteFolderDataFromDB start');
    if (this.table.isRdbStoreNotExist()) {
      await this.table.getRdbStore(STORE_CONFIG);
    }
    let favoriteList: FavoriteModel[] = [];
    let resultSet: rdb.ResultSet | undefined;
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.orderByAsc(FavoriteDataEnum.COLUMN_SORT_INDEX);

    try {
      resultSet = await this.table.queryTableData(predicates);
      if (!resultSet) {
        HiLog.warn(TAG, 'queryFavoriteFolderDataFromDB: resultSet is undefined!');
        return favoriteList;
      }
      HiLog.info(TAG, 'queryFavoriteFolderDataFromDB: rowCount: ' + resultSet.rowCount);
      while (resultSet.goToNextRow()) {
        const favoriteModel: FavoriteModel = this.transferFavoriteModel(resultSet);
        favoriteList.push(favoriteModel);
      }
    } catch (error) {
      HiLog.error(TAG, `queryFavoriteFolderDataFromDB error: ${error?.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    HiLog.info(TAG, 'queryFavoriteFolderDataFromDB end ' + favoriteList.length);
    return favoriteList;
  }

  /**
   * FavoritesFolderArray数据插入 (PC用）
   *
   * @param favoriteModel 插入的收藏数据
   * @returns 返回插入成功的数据id
   */
  public async insertFavoritesFolderToDB(favoriteModel: FavoriteModel): Promise<number> {
    HiLog.infoPrivate(TAG, 'insertFavoritesFolderToDB start ', favoriteModel.path);
    let id: number = 0;
    await this.initRdbStore();
    const valuesBucket: ValuesBucket = this.generateBucket(favoriteModel);
    try {
      HiLog.info(TAG, `insertFavoritesFolderToDB Value: ${JSON.stringify(valuesBucket)}`);
      id = await this.table.insertData(valuesBucket);
      HiLog.info(TAG, `insertFavoritesFolderToDB end, data : ${id}`);
    } catch (err) {
      HiLog.error(TAG, `insertFavoritesFolderToDB error: ${JSON.stringify(err)}`);
    }
    return id;
  }

  /**
   * 根据数据对应值，批量删除收藏数据,不区分账号，只通过id删除
   *
   * @param valueList 条件列表
   * @param dataStatus 如果需要过滤文件状态，可以指定
   * @returns 返回删除个数
   */
  public async deleteDataByValueList(
    valueList: Array<number>,
    dataStatus: number = Constant.FILE_RECYCLED.UNKNOWN): Promise<number> {
    let deleteCount = 0;
    if (ObjectUtil.isNullOrUndefined(valueList) || ArrayUtil.isEmpty(valueList)) {
      HiLog.info(TAG, 'deleteDataByValueList:valueList is empty');
      return deleteCount;
    }
    HiLog.info(TAG, 'deleteDataByValueList start');
    await this.initRdbStore();
    try {
      HiLog.info(TAG, `deleteDataByValueList :id  in  ${JSON.stringify(valueList)}`);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      if (dataStatus === Constant.FILE_RECYCLED.NORMAL) {
        predicates.equalTo(FavoriteDataEnum.COLUMN_RECYCLED, FavoriteModelUtil.getRecycledStatus(false));
        predicates.and();
      } else if (dataStatus === Constant.FILE_RECYCLED.DELETED) {
        predicates.equalTo(FavoriteDataEnum.COLUMN_RECYCLED, FavoriteModelUtil.getRecycledStatus(true));
        predicates.and();
      }
      predicates.in(FavoriteDataEnum.COLUMN_ID, valueList);

      deleteCount = await this.table.deleteData(predicates);
      HiLog.info(TAG, `deleteDataByValueList end, data : ${deleteCount}`);
    } catch (err) {
      HiLog.error(TAG, `deleteDataByValueList error: ${JSON.stringify(err)}`);
    }
    return deleteCount;
  }

  /**
   * 根据数据对应值，批量删除本地收藏数据
   *
   * @param valueList 条件列表
   * @param field 批量删除对应的列
   * @param dataStatus 如果需要过滤文件状态，可以指定
   * @returns 返回删除个数
   */
  public async deleteLocalDataByValueList(
    valueList: Array<ValueType>,
    field: string = FavoriteDataEnum.COLUMN_ID,
    dataStatus: number = Constant.FILE_RECYCLED.UNKNOWN): Promise<number> {
    let deleteCount = 0;
    if (ObjectUtil.isNullOrUndefined(valueList) || ArrayUtil.isEmpty(valueList)) {
      HiLog.info(TAG, 'deleteLocalDataByValueList:valueList is empty');
      return deleteCount;
    }
    HiLog.info(TAG, 'deleteLocalDataByValueList start');
    await this.initRdbStore();
    try {
      HiLog.info(TAG, `deleteLocalDataByValueList :${field}  in  ${JSON.stringify(valueList)}`);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      if (dataStatus === Constant.FILE_RECYCLED.NORMAL) {
        predicates.equalTo(FavoriteDataEnum.COLUMN_RECYCLED, FavoriteModelUtil.getRecycledStatus(false));
        predicates.and();
      } else if (dataStatus === Constant.FILE_RECYCLED.DELETED) {
        predicates.equalTo(FavoriteDataEnum.COLUMN_RECYCLED, FavoriteModelUtil.getRecycledStatus(true));
        predicates.and();
      }
      predicates.in(field, valueList);

      deleteCount = await this.table.deleteData(predicates);
      HiLog.info(TAG, `deleteLocalDataByValueList end, data : ${deleteCount}`);
    } catch (err) {
      HiLog.error(TAG, `deleteLocalDataByValueList error: ${JSON.stringify(err)}`);
    }
    return deleteCount;
  }

  /**
   * 根据路径更新收藏数据
   *
   * @param favorite 更新的收藏对象
   * @param path 更新额数据对应的path
   * @returns 返回更新的条数
   */
  public async updateFavoriteDataByPath(favorite: FavoriteModel, path: string): Promise<number> {
    HiLog.info(TAG, 'updateFavoriteDataByPath enter');
    let updateCount = 0;
    if (ObjectUtil.isNullOrUndefined(favorite) || ObjectUtil.isNullOrUndefined(path) || StringUtil.isEmpty(path)) {
      HiLog.info(TAG, 'params is undefined');
      return updateCount;
    }
    await this.initRdbStore();
    try {
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      predicates.equalTo(FavoriteDataEnum.COLUMN_PATH, path);
      let valuesBucket: ValuesBucket = this.generateBucket(favorite);
      updateCount = await this.table.updateData(valuesBucket, predicates);
      HiLog.info(TAG, `updateFavoriteDataByPath end, data : ${updateCount}`);
    } catch (err) {
      HiLog.error(TAG, `updateFavoriteDataByPath error: ${JSON.stringify(err)}`);
    }
    return updateCount;
  }

  /**
   * 根据id更新favoriteModel
   * @param favoritesFolder 收藏夹
   * @param id 主键
   * @returns
   */
  public async updateFavoriteFolderById(favoriteModel: FavoriteModel, id: number): Promise<boolean> {
    HiLog.infoPrivate(TAG, 'updateFavoriteFolderById', 'start id = ' + id + ', uri = ' + favoriteModel.path);
    await this.initRdbStore();
    try {
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      predicates.equalTo(FavoriteDataEnum.COLUMN_ID, id);
      let valuesBucket: ValuesBucket = this.generateBucket(favoriteModel);
      const updateCount: number = await this.table.updateData(valuesBucket, predicates);
      HiLog.info(TAG, `updateFavoriteFolderById end, data : ${updateCount}`);
      return true;
    } catch (err) {
      HiLog.error(TAG, `updateFavoriteFolderById error: ${JSON.stringify(err)}`);
    }
    return false;
  }

  /**
   * 文件夹上右键“添加到快速访问”
   *
   * @param name 文件名
   * @param uri 文件uri
   */
  public async addItemByRightMenu(name: string, uri: string): Promise<boolean> {
    HiLog.infoPrivate(TAG, 'addItemByRightMenu uri:', uri);
    let items = await this.queryFavoriteFolderDataFromDB();
    if (items.length >= this.MAX_LENGTH) {
      // 弹窗:最多收藏100个
      return false;
    }
    for (let i = 0; i < items.length; i++) {
      if (items[i].path === uri) {
        return true;
      }
    }
    let uuid = 'LOCAL';
    if (ExternalStorageUtil.isExternalStorageUri(uri)) {
      uuid = ExternalStorageUtil.getUUIDFromUri(uri);
    }
    let item: FavoriteModel = new FavoriteModel();
    item.name = name;
    item.path = uri;
    item.externalStorageUUID = uuid;
    item.sortIndex = items[items.length - 1].sortIndex + 1;
    items.push(item);
    let count = await this.insertFavoritesFolderToDB(item);
    return this.handleResult(count);
  }

  /**
   * 快速访问项目上右键“从快速访问移除”
   *
   * @param sortIndex 被移除文件夹在快速访问的位置
   */
  public async deleteItemByRightMenu(sortIndex: number): Promise<boolean> {
    HiLog.info(TAG, 'deleteItemByRightMenu sortIndex: ' + sortIndex);
    let items = await this.queryFavoriteFolderDataFromDB();
    const removedItem = items.splice(sortIndex, 1);
    if (removedItem.length > 0 && removedItem[0]) {
      let count = await this.deleteDataByValueList([removedItem[0].id]);
      return this.handleResult(count);
    }
    return false;
  }

  /**
   * 文件夹被删除后的回调函数
   *
   * @param srcUri 文件夹原始Uri
   */
  public async onFolderDeleted(items: FavoriteModel[], srcUris: string[]): Promise<number> {
    HiLog.info(TAG, 'start to delete from FavoriteDB');
    let matchedItems: number[] = [];
    for (const uri of srcUris) {
      for (const item of items) {
        if (uri === item.path || item.path.startsWith(`${uri}/`)) {
          matchedItems.push(item.id);
          break;
        }
      }
    }
    HiLog.infoPrivate(TAG, 'remove items:', JSON.stringify(items));
    const successNum: number = await this.deleteDataByValueList(matchedItems);
    return successNum;
  }

  /**
   * U盘被删除时需同步删除快速访问区收藏的该U盘中的文件夹
   *
   * @param uuid U盘盘符
   */
  public async diskDeleted(uuid: string): Promise<boolean> {
    HiLog.infoPrivate(TAG, 'diskDeleted uuid: ', uuid);
    let count = 0;
    let items = await FavoriteDbManager.getInstance().queryFavoriteFolderDataFromDB();
    for (let i = items.length - 1; i >= 0; i--) {
      if (items[i].externalStorageUUID === uuid) {
        const removedItem = items.splice(i, 1);
        count = await FavoriteDbManager.getInstance().deleteDataByValueList([removedItem[0].id]);
      }
    }
    return this.handleResult(count);
  }

  /**
   * 初始化数据库操作对象，最多尝试3次
   *
   * @param context 应用Context
   */
  protected async initRdbStore(): Promise<void> {
    if ((!this.rdbCreateSuccess) || this.table.isRdbStoreNotExist()) {
      this.rdbCreateSuccess = await this.table.getRdbStore(STORE_CONFIG);
    }

    if ((!this.rdbCreateSuccess) || this.table.isRdbStoreNotExist()) {
      HiLog.warn(TAG, 'rdbCreateFail,try first time:');
      await TimeUtil.sleep(10);
      this.rdbCreateSuccess = await this.table.getRdbStore(STORE_CONFIG);
    }

    if ((!this.rdbCreateSuccess) || this.table.isRdbStoreNotExist()) {
      HiLog.warn(TAG, 'rdbCreateFail,try second time:');
      await TimeUtil.sleep(10);
      this.rdbCreateSuccess = await this.table.getRdbStore(STORE_CONFIG);
    }

    // 初始化最近删除表
    if ((!this.rdbCreateSuccessRecent) || this.tableRecent.isRdbStoreNotExist()) {
      this.rdbCreateSuccessRecent = await this.tableRecent.getRdbStore(STORE_CONFIG);
    }

    for (let i = 0; i < 2; i++) {
      if ((!this.rdbCreateSuccessRecent) || this.tableRecent.isRdbStoreNotExist()) {
        HiLog.warn(TAG, `rdbRecentCreateFail,try ${i + 1} time`);
        await TimeUtil.sleep(10);
        this.rdbCreateSuccessRecent = await this.tableRecent.getRdbStore(STORE_CONFIG);
      }
    }
  }

  /**
   * 数据插入
   *
   * @param favoriteList 插入的收藏数据
   * @returns 返回插入成功的数据值
   */
  protected async insertToDB(favoriteList: FavoriteModel[]): Promise<number> {
    HiLog.info(TAG, 'insertToDB start');
    let insertCount = 0;
    if (ArrayUtil.isEmpty(favoriteList)) {
      HiLog.warn(TAG, 'insert list  is empty');
      return insertCount;
    }
    await this.initRdbStore();
    let valuesBuckets: ValuesBucket[] = [];
    let maxIndex = 0;
    favoriteList.forEach((item) => {
      let valuesBucket: ValuesBucket = this.generateBucket(item);
      if (maxIndex < item.sortIndex) {
        maxIndex = item.sortIndex;
      }
      valuesBuckets.push(valuesBucket);
    });
    if (this.MAX_INDEX < maxIndex) {
      this.MAX_INDEX = maxIndex;
    }
    try {
      HiLog.info(TAG, `insertToDB Value: ${valuesBuckets.length}`);
      insertCount = await this.table.batchInsertData(valuesBuckets);
      HiLog.info(TAG, `insertToDB end, data : ${insertCount}`);
      return insertCount;
    } catch (err) {
      HiLog.error(TAG, `insertToDB error: ${JSON.stringify(err)}`);
      return insertCount;
    }
  }

  /**
   * 更新收藏缓存数据
   *
   * @param favoriteList 更新的收藏列表
   */
  private addFavoriteCacheList(favoriteList: FavoriteModel[]): void {
    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      this.favoriteCache = [];
    }
    if (!ArrayUtil.isEmpty(favoriteList)) {
      let tempList = favoriteList.reverse();
      let len = tempList.length;
      for (let i = 0; i < len; i++) {
        this.favoriteCache.splice(0, 0, tempList[i]);
      }
    }
  }

  /**
   * 校验收藏查询参数合法性
   *
   * @param fileList 对比的文件列表
   * @returns true：参数正常
   */
  private checkFavoriteParams(fileList: FileInfo[]): boolean {
    if (ArrayUtil.isEmpty(fileList)) {
      HiLog.info(TAG, 'checkFavoriteParams:fileList is empty');
      return false;
    }

    if (ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.info(TAG, 'checkFavoriteParams:favoriteCache is empty');
      return false;
    }

    return true;
  }

  /**
   * 校验删除参数合法性
   *
   * @param fileDataList  删除的文件列表
   * @returns true：参数正常
   */
  private checkDeleteParams(fileDataList: FileInfo[]): boolean {
    if (ObjectUtil.isNullOrUndefined(fileDataList) || ArrayUtil.isEmpty(fileDataList) ||
    ArrayUtil.isEmpty(this.favoriteCache)) {
      return false;
    }
    return true;
  }

  private checkReNameParams(oldPath: string, newPath: string, newFileName: string): boolean {
    if (ObjectUtil.isNullOrUndefined(oldPath) || ObjectUtil.isNullOrUndefined(newPath) ||
    ObjectUtil.isNullOrUndefined(newFileName)) {
      HiLog.warn(TAG, 'oldPath or newPath is Undefined');
      return false;
    }

    if (StringUtil.isEmpty(oldPath) || StringUtil.isEmpty(newPath) || StringUtil.isEmpty(newFileName)) {
      HiLog.warn(TAG, 'oldPath or newPath is empty');
      return false;
    }
    return true;
  }

  /**
   * 处理返回结果，即将数据库返回值转换为bool值
   *
   * @param resultCount 数据库返回值
   * @returns true：说明数据库变化值大于0
   */
  private handleResult(resultCount: number = 0): boolean {
    return resultCount > 0;
  }

  /**
   * 获取当前目录或者子目录的index
   *
   * @param folderList 查询的目标列表
   * @param path 查询的路径
   * @returns 返回索引，大于-1，即找到对应对象
   */
  private getPathAndSubPathIndex(folderList: FileInfo[] = [], path: string): number {
    return folderList.findIndex(item => item.relativePath === path ||
    path.startsWith(FileUtil.getPathWithFileSplit(item.relativePath)));
  }

  private transferFavoriteModel(resultSet: rdb.ResultSet): FavoriteModel {
    return new FavoriteModel(
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_ID)),
      resultSet.getString(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_NAME)),
      resultSet.getString(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_PATH)),
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_MODIFY_TIME)),
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_SET_TIME)),
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_RECYCLED)),
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_DEVICE_TYPE)),
      resultSet.getString(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_EXT_UUID)),
      resultSet.getLong(resultSet.getColumnIndex(FavoriteDataEnum.COLUMN_SORT_INDEX))
    );
  }

  /**
   * 过滤规则：
   * 1、根据本地挂载，清理不是当前挂载目录的本地数据，例如U盘数据
   * 2、因使用场景，导致部分数据没有及时清理的文件夹不存在的数据、重复的数据
   * 3、需要按照recycled状态，分开处理重复数据
   *
   * @param favoriteModel 需要过滤的收藏对象
   * @param deviceList 当前挂载设备列表
   * @param favoriteList 处理之后的收藏列表
   * @param recordPathList 标记已经存在文件路径
   * @param needClearIdList 需要清理的数据
   */
  private async filterData(
    favoriteModel: FavoriteModel,
    deviceList: DiskInfo[] = [],
    favoriteList: FavoriteModel[] = [],
    recordPathList: string[] = [],
    needClearIdList: Array<number> = []): Promise<void> {
    // 本地、U盘
    /**
     * 本地：
     *     若uri存在，则不删除不过滤
     *     若uri不存在，则过滤且删除
     * U盘：若U盘不在设备列表中，则过滤记录，不删除；
     *     若在设备列表中，判断uri是否存在
     *         若uri存在，则不删除不过滤
     *         若uri不存在，则过滤且删除
     */
    let favoriteUri: string = FileUtil.getUriFromPath(favoriteModel.path);
    let isExternalFile: boolean = ExternalStorageUtil.isExternalStorageUri(favoriteUri);
    if (isExternalFile) {
      const isDeviceExist: boolean = this.checkUsbDeviceExist(deviceList, favoriteModel.path);
      if (!isDeviceExist) {
        HiLog.warn(TAG, 'external device not exist, filter data');
        return;
      }
    }
    // 此目录是否已经记录
    const contain = recordPathList.includes(favoriteModel.path);
    if (contain) {
      const index = favoriteList.findIndex(item => item.path === favoriteModel.path)
      if (index === -1) {
        favoriteList.push(favoriteModel);
        return;
      }
      // 目录已经被记录，需要判断被记录的那个是否是已经被删除的数据并且过滤数据是正常显示的，需要移除
      const tempFavoriteModel = favoriteList[index]
      if ((!favoriteModel.recycled) && tempFavoriteModel.recycled) {
        favoriteList.splice(index, 1, favoriteModel);
      }
      HiLog.warn(TAG, 'delete favoriteModel, reason: dirty data exists.')
      needClearIdList.push(favoriteModel.id);
    } else {
      if (!favoriteModel.recycled) {
        // 展示的数据，需要判断目录是否存在，不存在需要登记移除
        const isFolderExist = await FileUtil.isExistByPathWithFs(favoriteModel.path);
        if (!isFolderExist) {
          needClearIdList.push(favoriteModel.id);
          HiLog.warn(TAG, 'delete favoriteModel, reason: folder is not Exist')
          return;
        }
      }
      recordPathList.push(favoriteModel.path);
      favoriteList.push(favoriteModel);
    }
  }

  private getFavoriteIndex(favoriteList: FavoriteModel[] = [], path: string): number {
    return favoriteList.findIndex(item => item.path === path);
  }

  private checkUsbDeviceExist(deviceList: DiskInfo[], path: string): boolean {
    if (ObjectUtil.isNullOrUndefined(path) || StringUtil.isEmpty(path)) {
      return false;
    }

    if (ArrayUtil.isEmpty(deviceList)) {
      return true;
    }
    const deviceIndex = deviceList.findIndex((item: DiskInfo) => {
      HiLog.infoPrivate(TAG, 'delete favoriteModel', 'deviceList: ' + item.relativePath);
      return item.relativePath === path || path.startsWith(FileUtil.getPathWithFileSplit(item.relativePath))
    })
    return deviceIndex !== -1;
  }

  private generateBucket(item: FavoriteModel): ValuesBucket {
    let obj: ValuesBucket = {
      [FavoriteDataEnum.COLUMN_NAME]: item.name,
      [FavoriteDataEnum.COLUMN_PATH]: item.path,
      [FavoriteDataEnum.COLUMN_MODIFY_TIME]: item.modifyTime,
      [FavoriteDataEnum.COLUMN_SET_TIME]: item.setTime,
      [FavoriteDataEnum.COLUMN_RECYCLED]: FavoriteModelUtil.getRecycledStatus(item.recycled),
      [FavoriteDataEnum.COLUMN_DEVICE_TYPE]: FavoriteModelUtil.getNumberByDeviceType(item.deviceType),
      [FavoriteDataEnum.COLUMN_EXT_UUID]: item.externalStorageUUID,
      [FavoriteDataEnum.COLUMN_SORT_INDEX]: item.sortIndex
    };
    return obj;
  }

  /**
   * 清除所有被标记为软删除的数据
   *
   * @returns 返回清除的数据的条数
   */
  private async deleteLocalRecycledData(): Promise<number> {
    let deleteCount = 0;
    HiLog.info(TAG, 'deleteLocalRecycledData enter');
    await this.initRdbStore();
    try {
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      predicates.equalTo(FavoriteDataEnum.COLUMN_RECYCLED, FavoriteModelUtil.getRecycledStatus(true));
      predicates.and();
      deleteCount = await this.table.deleteData(predicates);
      HiLog.info(TAG, `deleteLocalRecycledData end, data : ${deleteCount}`);
    } catch (err) {
      HiLog.error(TAG, `deleteLocalRecycledData error code: ${err?.code}, error message: ${err?.message}`);
    }
    return deleteCount;
  }
}