/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import fileuri from '@ohos.file.fileuri';
import { CopyCutResultParam } from '../../workermanager/copycutmanager/CopyCutResultParam';
import { FsUtil } from '../../utils/FsUtil';
import WorkerConst from '../../worker/WorkerConst';
import type { ThreadWorkerGlobalScope } from '@ohos.worker';
import { HiLog } from '../../dfx/HiLog';
import { FileUtil } from '../../fileoperate/FileUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { PasteFlag } from '../../const/FilePasteConstants';
import { Constant } from '../../const/Constant';
import { ProgressBarStatus } from '../../workermanager/copycutmanager/CopyCutSendParam';
import { RenameUtil } from '../../fileoperate/RenameUtil';
import { VirtualUri } from '../../const/FolderRecord';

const TAG = 'ThreadCommonUtil';
// 重复文件名序号起始值
const DUP_NAME_BEGIN_NUM: number = 2;
// 复制粘贴显示进度条的大小阈值
const MULTI_THREAD_COPY_FILE_SIZE = 524288000; // 500M
const MULTI_THREAD_COPY_FILE_NUM = 200;

export class ThreadCommonUtil {
  /**
   * 判断是否显示进度条，仅通过文件size和文件数判断，如果满足，在主线程直接起进度条，worker不再判断，如果存在文件夹，在子线程中再次判断
   * @param toOperateFiles
   * @returns
   */
  public static isShowProgressByFileSize(toOperateFiles: FileInfo[], pasteFlag: PasteFlag,
    isOperateAcrossDisk: boolean, isLocalAppFile: boolean): ProgressBarStatus {
    if (pasteFlag === PasteFlag.CUT && !isOperateAcrossDisk && isLocalAppFile) {
      // 同设备同盘剪切不显示进度条
      return ProgressBarStatus.NOT_PULL_UP;
    }
    if (toOperateFiles.length >= MULTI_THREAD_COPY_FILE_NUM) {
      return ProgressBarStatus.NEEDS_TO_BE_PULLED_UP;
    }
    let totalSize: number = 0;
    let totalCount: number = 0;
    for (let i = 0; i < toOperateFiles.length; i++) {
      let file = toOperateFiles[i];
      if (!file.isFolder) {
        totalSize += file.size;
        totalCount++;
        if (totalSize >= MULTI_THREAD_COPY_FILE_SIZE) {
          return ProgressBarStatus.NEEDS_TO_BE_PULLED_UP;
        }
      }
    }
    // 全部是文件的场景
    if (totalCount === toOperateFiles.length) {
      return ProgressBarStatus.NOT_PULL_UP;
    }
    return ProgressBarStatus.NOT_JUDGED;
  }

  /**
   * 判断是否显示进度条
   * @param toOperateFiles
   * @returns
   */
  public static isShowProgress(totalSize: number, totalCount: number,
    pasteFlag: PasteFlag, isOperateAcrossDisk: boolean,
    isLocalAppFile: boolean): boolean {
    if ((pasteFlag === PasteFlag.CUT) && (!isOperateAcrossDisk && isLocalAppFile)) {
      // 同设备同盘剪切不显示进度条
      return false;
    }
    if ((totalSize >= MULTI_THREAD_COPY_FILE_SIZE) || (totalCount >= MULTI_THREAD_COPY_FILE_NUM)) {
      return true;
    }
    return false;
  }

  /**
   * 获取worker线程名称
   * @param workerTag 线程名称标识，复制粘贴使用destFolderUri，删除还原使用操作TAG
   * @returns worker线程名称
   */
  public static getWorkerName(workerNameTag: string, isDesktopOptService: boolean = false): string {
    let workerName: string = workerNameTag + '_';
    if (isDesktopOptService) { // 桌面启动的worker，添加关键字，添加标志位
      HiLog.info(TAG, 'is desktop worker');
      workerName += Constant.DESKTOP_TAG;
    }
    workerName += Date.now();
    return workerName;
  }

  public static getTimeByWorkerName(workerName: string): number {
    let splitIndex: number = workerName.lastIndexOf('_');
    if ((workerName === '') || (splitIndex === -1) || (splitIndex === 0)) {
      HiLog.info(TAG, 'getTimeByWorkerName, invalid worker name');
      return 0;
    }
    return Number.parseInt(workerName.substring(splitIndex));
  }

  /*
   * 外接存储设备内通过uri获取父路径uri
   * */
  public static getParentUri(uri: string): string {
    let lastIndex = uri.lastIndexOf('/');
    let parentUri = uri.substring(0, lastIndex);
    return parentUri;
  }

  /*
   * 若uri末尾带'/',去除uri末尾'/'
   * */
  public static getNoSlashUri(uri?: string): string {
    if (!uri) {
      return '';
    }
    if (uri.endsWith('/')) {
      return uri.substring(0, uri.lastIndexOf('/'));
    }
    return uri;
  }

  /**
   * 通过uri获取文件名
   * @param uri 文件uri
   * @returns 文件名
   */
  public static getFileNameByUri(uri: string): string {
    let lastIndex = uri.lastIndexOf('/');
    let fileName = uri.substring(lastIndex + 1, uri.length);
    return fileName;
  }

  /**
   * 根据文件夹uri和文件名拼接子文件uri
   * @param folderUri 文件夹uri
   * @param fileName 文件夹下的某一个文件的文件名
   * @returns 拼接好的文件uri
   */
  public static getSubFileUri(folderUri: string, fileName: string): string {
    let subUri: string = '';
    subUri = folderUri + '/' + FileUtil.encodeURIForFileManager(fileName);
    HiLog.infoPrivate(TAG, 'subUri: ', subUri);
    return subUri;
  }

  /**
   * 获取源文件在目标文件夹中下一个副本文件名称（dupFileResult[0]） 以及 和源文件重名的文件的uri(dupFileResult[1])
   * 如果目标文件夹中不存在与源文件重名的文件，则返回源文件名称
   * @param srcFileName 源文件名称
   * @param destFolder 目标文件夹
   * @param isFolder 源文件是否是文件夹
   */
  public static getDupFileName(srcFileName: string, destFolderUri: string, isFolder: boolean): string[] {
    let escapedFileName: string;
    if (isFolder) {
      escapedFileName = RenameUtil.getEscapedFolderName(srcFileName);
    } else {
      escapedFileName = RenameUtil.getEscapedFileName(srcFileName);
    }
    return ThreadCommonUtil.getRawDupFileName(escapedFileName, destFolderUri);
  }

  public static getDupFileResult(srcPrefix: string, srcSuffix: string, num: number): string {
    let numAndSrcSuffix: string = ' (' + num + ')' + srcSuffix;
    let result: string = srcPrefix + numAndSrcSuffix;
    while (ThreadCommonUtil.getByteLen(result) > Constant.MAX_FILENAME_LENGTH) {
      // 为减少文件名称长度，前缀截去后10个字符，规格为产品经理所确定
      srcPrefix = srcPrefix.substring(0, srcPrefix.length - 10);
      result = srcPrefix + numAndSrcSuffix;
    }
    return result;
  }

  public static getByteLen(fileName: string): number {
    let len = 0;
    for (let i = 0; i < fileName.length; i++) {
      const char = fileName.charAt(i);
      if (char.match(/[^\x00-\xff]/ig) !== null) { // 若为中文字符，则为3个字节
        len += 3;
      } else if (char.match(/[\w().]/)) { // 若为字母数字下划线等常见字符，则为1个字节
        len++;
      } else { // 否则为两个字节
        len += 2;
      }
    }
    return len;
  }

  /**
   * 判断是否粘贴至子文件夹
   * @param srcFolderUri：要粘贴的文件夹uri
   * @param destUri：目标路径uri
   * @returns 判断结果
   */
  public static isChildFolder(srcFolderUri: string, destFolderUri: string): boolean {
    HiLog.infoPrivate(TAG, 'isChildFolder', ' srcFolderUri : ' + srcFolderUri + ' dest uri = ' + destFolderUri);
    let tempSrcFolderUri = srcFolderUri + '/';
    let tempDestFolderUri = destFolderUri + '/';
    let isAlbumToGallery: boolean =
      destFolderUri.startsWith(VirtualUri.GALLERY_URI) && destFolderUri === srcFolderUri;
    return tempDestFolderUri.includes(tempSrcFolderUri) || isAlbumToGallery;
  }

  /**
   * 发送进度信息
   * @param size
   * @param fileName
   */
  public static sendProgressInfo(workerPort: ThreadWorkerGlobalScope, workerName: string, pasteProgressRate: number,
    operatingFileName: string, operateType: WorkerConst.OperateType): void {
    let resultParam = new CopyCutResultParam(
      workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.PROGRESS,
      operateType,
      operatingFileName,
      pasteProgressRate
    );
    HiLog.info(TAG, 'updatePasteProgress, pasteProgressRate: ' + resultParam.pasteProgressRate);
    workerPort.postMessage(resultParam);
  }

  /**
   * 判断是否将同名子文件夹复制或者剪切到同名父文件夹的同路径下
   * @param srcFileInfo 要粘贴的文件FileInfo信息
   * @param destFolderUri 目标路径uri
   * @returns
   */
  public static isOperateDupFolderFromChildToParent(srcFileInfo: FileInfo, destFolderUri: string): boolean {
    if (!srcFileInfo.isFolder) {
      return false;
    }
    let isExistDupName: boolean = FsUtil.isExistDupName(destFolderUri, srcFileInfo.fileName); // 是否存在同名文件夹
    if (!isExistDupName) {
      return false;
    }
    let isOperateFromChildToParent: boolean =
      ThreadCommonUtil.isOperateFromChildToParent(srcFileInfo, destFolderUri); // 是否从子文件夹复制或者剪切到父文件夹
    return isOperateFromChildToParent;
  }

  private static getRawDupFileName(srcFileName: string, destFolderUri: string): string[] {
    let result: string[] = ['', ''];
    if ((!srcFileName) || (!destFolderUri)) {
      HiLog.error(TAG, 'getRawDupFileName, params is error');
      return result;
    }

    let srcPrefixAndSuffix: string[] = FileUtil.getPrefixAndSuffix(srcFileName);
    let destFolderPath: string = new fileuri.FileUri(destFolderUri).path;
    if (!FsUtil.isExistSyncByPath(destFolderPath)) {
      HiLog.error(TAG, 'dest folder not exist');
      return srcPrefixAndSuffix;
    }

    let destFileName: string = srcFileName;
    let serialNum: number = 1;
    while (FsUtil.isExistDupName(destFolderPath, destFileName)) {
      // 若两个文件名称相同，对result[1]进行赋值，记录与源文件重名的文件的uri
      if (destFileName === srcFileName) {
        result[1] = destFolderUri + '/' + FileUtil.encodeURIForFileManager(destFileName);
      }

      serialNum++;
      destFileName = ThreadCommonUtil.getDupFileResult(srcPrefixAndSuffix[0], srcPrefixAndSuffix[1], serialNum);
    }
    result[0] = destFileName;
    HiLog.infoPrivate(TAG, 'getRawDupFileName end: ', `srcFileName: ${srcFileName}, result[0]: ${result[0]}`);
    return result;
  }

  /**
   * 判断是否从子文件夹到父文件夹进行操作
   * @param srcFileInfo：要粘贴的文件FileInfo信息
   * @param destUri：目标路径uri
   * @returns 判断结果
   */
  private static isOperateFromChildToParent(srcFileInfo: FileInfo, destFolderUri: string): boolean {
    HiLog.infoPrivate(TAG, 'isOperateFromChildToParent',
      'srcFolderUri : ' + srcFileInfo.uri + ' dest uri = ' + destFolderUri);
    let tempDestFolderUri = destFolderUri + '/' + FileUtil.encodeURIForFileManager(srcFileInfo.fileName) + '/';
    return srcFileInfo.uri.includes(tempDestFolderUri);
  }
}