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
// animation
import CustomNavigationUtilTest from './common/animation/CustomNavigationUtil.test';
import TransitionAnimationControllerTest from './common/animation/TransitionAnimationController.test'

// config
import AppConfigTest from "./common/config/AppConfig.test";

// const
import MyPhoneConstantTest from "./common/const/MyPhoneConstant.test";
import FileOperationTypeTest from "./common/const/FileOperationType.test";

// data
import DeviceConfigTest from "./common/data/DeviceConfigTest.test";

// database
import RdbTest from "./common/database/Rdb.test";

// dragfile
import DragManagerTest from "./common/dragfile/DragManager.test";
import UdmfUtilsTest from "./common/dragfile/UdmfUtils.test";

// etsexport
import FilePickerUtilTest from "./common/etsexport/utils/FilePickerUtil.test";
import PhoneFilePickerUtilTest from "./common/etsexport/utils/PhoneFilePickerUtil.test";
import FileGroupDataSourceTest from "./common/etsexport/lazyLoadData/FileGroupDataSource.test";
import GroupDataSourceTest from "./common/etsexport/lazyLoadData/GroupDataSource.test";
import BasicDataSourceTest from "./common/etsexport/lazyLoadData/BasicDataSource.test"
import ThumbnailLoadTest from "./common/etsexport/resourceLoad/ThumbnailLoad.test";
import ResourceCacheUtilTest from "./common/etsexport/utils/ResourceCacheUtil.test";
import DuplicateFilesDataSourceTest from './common/etsexport/lazyLoadData/DuplicateFilesDataSource.test';

// extension
import ReceiveEventUtilTest from "./common/extension/ReceiveEventUtil.test";
import UIExtSessionManagerTest from "./common/extension/UIExtSessionManager.test";

// externel
import AccountManagerTest from "./common/externel/AccountManager.test";

// fileOperate
import FileAccessUtilTest from "./common/fileoperate/FileAccessUtil.test";
import FileOperationTest from "./common/fileoperate/FileOperation.test";
import RenameUtilTest from "./common/fileoperate/RenameUtil.test";
import TransferringModelTest from "./common/fileoperate/TransferringModel.test";
import FileOperateCreateTest from "./common/fileoperate/FileOperateCreate.test";

// fileSort
import FileGroupTest from "./common/filesort/FileGroup.test";
import FileSortParamUtilTest from "./common/filesort/FileSortParamUtil.test";

// lazyLoadData
import BasicDataSourceTest2 from "./common/lazyLoadData/BasicDataSource.test";

// media
import MediaMetaDataUtilTest from "./common/media/MediaMetaDataUtil.test";
import MediaThumbnailCacheUtilTest from "./common/media/MediaThumbnailCacheUtil.test";
import MediaThumbnailUtilTest from "./common/media/MediaThumbnailUtil.test";

// model
import ApplicationThemeColorTest from "./common/model/ApplicationThemeColor.test";
import StartModeOptionsTest from "./common/model/StartModeOptions.test";

// pasteboard
import PasteBoardManagerTest from "./common/pasteboard/PasteBoardManager.test";

// preference
import PreferenceFactoryTest from './common/preference/PreferenceFactory.test';

// security
import AegPbkdf2UtilTest from "./common/security/AegPbkdf2Util.test";
import AesCtrCryptoUtilTest from "./common/security/AesCtrCryptoUtil.test";
import AesGcmCryptoUtilTest from "./common/security/AesGcmCryptoUtil.test";
import CryptoCommonUtilTest from "./common/security/CryptoCommonUtil.test";
import SafeRandomUtilTest from "./common/security/SafeRandomUtil.test";

// taskpool
import TaskExecutorTest from "./common/taskpool/base/TaskExecutor.test";
import TaskManagerTest from "./common/taskpool/TaskManager.test";

// utils
import AbilityCommonUtilTest from "./common/utils/AbilityCommonUtil.test";
import AccessibilityManagerTest from "./common/utils/AccessibilityManager.test";
import AccountUtilTest from "./common/utils/AccountUtil.test";
import AppDataPathUtilTest from "./common/utils/AppDataPathUtil.test";
import ArrayUtilTest from "./common/utils/ArrayUtil.test";
import AssertExtUtilTest from "./common/utils/AssertExtUtil.test";
import AuditLogUtilsTest from "./common/utils/AuditLogUtils.test";
import CommonTest from "./common/utils/Common.test";
import CommonUtilTest from "./common/utils/CommonUtil.test";
import DateUtilTest from "./common/utils/DateUtil.test";
import FileMimeTypeUtilTest from "./common/utils/FileMimeTypeUtil.test";
import FilePreviewUtilTest from "./common/utils/FilePreviewUtil.test";
import LanguageUtilTest from "./common/utils/LanguageUtil.test";
import ObjectUtilTest from "./common/utils/ObjectUtil.test";
import ParseUtilTest from "./common/utils/ParseUtil.test";
import PrintUtilTest from "./common/utils/PrintUtil.test";
import SortUtilTest from "./common/utils/SortUtil.test";
import StoragePathUtilTest from "./common/utils/StoragePathUtil.test";
import StringUtilTest from "./common/utils/StringUtil.test";
import ThrottlingUtilTest from "./common/utils/ThrottlingUtil.test";
import DisplayUtilTest from './common/utils/DisplayUtil.test';
import TimePointTest from "./common/utils/TimePoint.test";
import UiUtilTest from "./common/utils/UiUtil.test";
import ToolsTest from "./common/utils/Tools.test";
import PasteUtilTest from "./common/utils/PasteUtil.test";
import HashUtilTest from "./common/utils/HashUtil.test";
import EventBusTest from "./common/utils/EventBus.test";
import FsUtilTest from "./common/utils/FsUtil.test";
import AbilityManagerUtilTest from "./common/utils/AbilityManagerUtil.test";
import FileDataUtilTest from "./common/utils/FileDataUtil.test";
import BundleResourceUtilTest from "./common/utils/BundleResourceUtil.test";
import TrashFileUtilTest from "./common/utils/TrashFileUtil.test"
import FileDefaultIconUtilTest from "./common/utils/FileDefaultIconUtil.test";
import DuplicateFilesUtilTest from  './common/utils/DuplicateFilesUtil.test';
import PhotoAccessUtilTest from "./common/utils/PhotoAccessUtil.test";
import ThumbnailUtilTest from "./common/utils/ThumbnailUtil.test";
import ResourceUtil from "./common/utils/ResourceUtil.test";
import PrivacyModeManagerTest from "./common/utils/PrivacyModeManager.test"

// work
import TaskObjectTest from "./common/work/TaskObject.test";
import WorkerHandlerTest from './common/work/WorkerHandler.test'
import WorkerPoolTest from "./common/work/WorkerPool.test";
import WorkerPoolManagerTest from "./common/work/WorkerPoolManager.test";

// workermanager
import CommonDeleteRestoreManagerTest
  from "./common/workermanager/deleterestoremanager/CommonDeleteRestoreManagerTest.test";
import MessageNotifyTest from "./common/workermanager/MessageNotifyTest.test";

// workeroperate
import FileCopyUtilTest from "./common/workeroperate/FileCopyUtilTest.test";
import ThreadCommonUtilTest from "./common/workeroperate/ThreadCommonUtil.test";

//privacy
import PrivacyUtilTest from './common/pravicy/PrivacyUtil.test'

// base manager
import MenuActionHandlerTest from './product/manager/MenuActionHandler.test';

export default function testsuite() {
  //animation
  CustomNavigationUtilTest();
  TransitionAnimationControllerTest();

  // config
  AppConfigTest();

  // const
  MyPhoneConstantTest();
  FileOperationTypeTest();

  // data
  DeviceConfigTest();

  // database
  RdbTest();

  // dragfile
  DragManagerTest();
  UdmfUtilsTest();

  // etsexport
  FilePickerUtilTest();
  PhoneFilePickerUtilTest();
  FileGroupDataSourceTest();
  GroupDataSourceTest();
  BasicDataSourceTest();
  ThumbnailLoadTest();
  ResourceCacheUtilTest();
  DuplicateFilesDataSourceTest();

  // extension
  ReceiveEventUtilTest();
  UIExtSessionManagerTest();

  // externel
  AccountManagerTest();

  // fileOperate
  FileAccessUtilTest();
  RenameUtilTest();
  TransferringModelTest();
  FileOperationTest();
  FileOperateCreateTest();

  // fileSort
  FileGroupTest();
  FileSortParamUtilTest();

  // lazyLoadData
  BasicDataSourceTest2();

  // media
  MediaMetaDataUtilTest();
  MediaThumbnailCacheUtilTest();
  MediaThumbnailUtilTest();

  // model
  StartModeOptionsTest();
  ApplicationThemeColorTest();

  // pasteboard
  PasteBoardManagerTest();

  // preference
  PreferenceFactoryTest();

  // security
  AegPbkdf2UtilTest();
  AesCtrCryptoUtilTest();
  AesGcmCryptoUtilTest();
  CryptoCommonUtilTest();
  SafeRandomUtilTest();

  // taskpool
  TaskExecutorTest();
  TaskManagerTest();

  // utils
  AbilityCommonUtilTest();
  AccessibilityManagerTest();
  AccountUtilTest();
  AppDataPathUtilTest();
  ArrayUtilTest();
  AssertExtUtilTest();
  AuditLogUtilsTest();
  CommonUtilTest();
  CommonTest();
  DateUtilTest();
  ParseUtilTest();
  ObjectUtilTest();
  FileMimeTypeUtilTest();
  FilePreviewUtilTest();
  LanguageUtilTest();
  SortUtilTest();
  StoragePathUtilTest();
  StringUtilTest();
  ThrottlingUtilTest();
  TimePointTest();
  UiUtilTest();
  DisplayUtilTest();
  PrintUtilTest();
  ToolsTest();
  PasteUtilTest();
  HashUtilTest();
  EventBusTest();
  FsUtilTest();
  AbilityManagerUtilTest();
  FileDataUtilTest();
  BundleResourceUtilTest();
  TrashFileUtilTest();
  FileDefaultIconUtilTest();
  PhotoAccessUtilTest();
  DuplicateFilesUtilTest();
  ThumbnailUtilTest();
  ResourceUtil();
  PrivacyModeManagerTest();

  // workeroperate
  ThreadCommonUtilTest();
  FileCopyUtilTest();

  // work
  TaskObjectTest();
  WorkerHandlerTest();
  WorkerPoolTest();
  WorkerPoolManagerTest();

  // workermanager
  CommonDeleteRestoreManagerTest();
  MessageNotifyTest();

  // privacy
  PrivacyUtilTest();

  // base manager
  MenuActionHandlerTest();
}