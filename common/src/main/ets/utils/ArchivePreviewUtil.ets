/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * 压缩包内浏览/部分解压工具（不依赖 PreviewKit）。
 */

import { FileInfo } from '../fileoperate/FileInfo';
import { FileUtil } from '../fileoperate/FileUtil';
import { HiLog } from '../dfx/HiLog';
import { AddressData } from '../model/address/AddressData';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import { compress } from '../workermanager/filecompressmanager/FileCompressSdk';
import { StandardErrCode } from '../workermanager/filecompressmanager/CompressStandardErrCode';
import fs from '@ohos.file.fs';
import { FileOperation } from '../fileoperate/FileOperation';
import { VirtualUri } from '../const/FolderRecord';
import { Constant } from '../const/Constant';
import { EventBus } from './EventBus';
// TODO: oh7zip 上库后恢复 import { DeCompressProp, GetArchiveInfoProp } from '@ohos/oh7zip';
// TODO: oh7zip 上库后恢复 import type { ArchiveFileInfo, CallbackArchiveInfo, CallbackCompress } from '@ohos/oh7zip';

class DeCompressProp {
  public inFile: string = '';
  public innerFiles?: string[] = undefined;
  public password?: string = undefined;
  public outDir: string = '';
  public outName?: string = undefined;
}

class GetArchiveInfoProp {
  public inFile: string = '';
  public password?: string = undefined;
}

class ArchiveFileInfo {
  public innerFile: string = '';
  public beforeSize: number = 0;
  public afterSize: number = 0;
  public isDir: boolean = false;
  public isEncrypted: boolean = false;
  public modifyTime: number = 0;
  public fileHash: string = '';
}

class CallbackArchiveInfo {
  public code: number = 0;
  public files: ArchiveFileInfo[] = [];
  public beforeSize: number = 0;
  public afterSize: number = 0;
  public filesNum: number = 0;
  public foldersNum: number = 0;
}

class CallbackCompress {
  public code: number = 0;
  public progress: number = 0;
  public file: string = '';
}

const TAG = 'ArchivePreviewUtil';
/** 压缩包后缀后跟包内路径时，视为虚拟 URI */
const ARCHIVE_INNER_MARKERS: string[] = ['.zip/', '.7z/', '.rar/', '.tar/', '.gz/', '.gzip/'];
/** 公共临时预览目录前缀（落在 Download 下，隐藏目录） */
const PREVIEW_DIR_PREFIX = Constant.ARCHIVE_PREVIEW_DIR_PREFIX;
/** 回到前台后稍延时再删，避免图库仍占用文件句柄 */
const CLEANUP_DELAY_MS = 1500;

export class ArchivePreviewError extends Error {
  public code: number;

  constructor(code: number, message: string) {
    super(message);
    this.code = code;
  }
}

export class ArchivePreviewUtil {
  private static pendingCleanupDirs: string[] = [];
  private static cleanupTimerId: number = -1;

  /**
   * 从面包屑中取压缩包根 URI
   */
  public static getArchiveRootUri(direList: AddressData[]): string {
    if (!direList) {
      return '';
    }
    for (let i = 0; i < direList.length; i++) {
      if (FileUtil.isArchiveByUri(direList[i].uri)) {
        return direList[i].uri;
      }
    }
    return '';
  }

  /**
   * 当前位于压缩包内的相对目录前缀（不含末尾 /）
   */
  public static getArchiveInnerPrefix(direList: AddressData[]): string {
    if (!direList) {
      return '';
    }
    let found = false;
    const parts: string[] = [];
    for (let i = 0; i < direList.length; i++) {
      if (FileUtil.isArchiveByUri(direList[i].uri)) {
        found = true;
        continue;
      }
      if (found && direList[i].name) {
        parts.push(direList[i].name);
      }
    }
    return parts.join('/');
  }

  /**
   * 是否为压缩包内条目的虚拟 URI（.../xxx.zip/内层路径）
   */
  public static isArchiveInnerUri(uri: string): boolean {
    if (!uri) {
      return false;
    }
    const path = (FileUtil.getPathFromUri(uri) || uri).toLowerCase();
    for (let i = 0; i < ARCHIVE_INNER_MARKERS.length; i++) {
      if (path.includes(ARCHIVE_INNER_MARKERS[i])) {
        return true;
      }
    }
    return false;
  }

  /**
   * 是否为需要密码的错误码
   */
  public static isPasswordRelatedCode(code: number): boolean {
    return code === StandardErrCode.ERR_COMPRESS_PASSWORD_NULL ||
      code === StandardErrCode.ERR_COMPRESS_PASSWORD_VERIFY_FAILED ||
      code === StandardErrCode.ERR_COMPRESS_FILE_NAME_ENCRYPTED;
  }

  /**
   * 读取压缩包信息
   */
  public static getArchiveInfo(archivePath: string, password: string = ''): Promise<CallbackArchiveInfo> {
    return new Promise((resolve, reject) => {
      const prop = new GetArchiveInfoProp();
      prop.inFile = archivePath;
      if (password) {
        prop.password = password;
      }
      const taskKey = `archive_info_${Date.now()}`;
      try {
        compress.getArchiveInfo(taskKey, prop, (data: CallbackArchiveInfo) => {
          resolve(data);
        });
      } catch (e) {
        HiLog.error(TAG, `getArchiveInfo throw: ${JSON.stringify(e)}`);
        reject(e);
      }
    });
  }

  /**
   * 规范化包内相对路径
   */
  public static normalizeInnerPath(innerFile: string): string {
    let path = innerFile || '';
    path = path.replace(/\\/g, '/');
    while (path.startsWith('./')) {
      path = path.substring(2);
    }
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  /**
   * 统计某目录下直接子项数量（与文管文件夹计数语义一致：文件+文件夹）
   */
  public static countDirectChildren(files: ArchiveFileInfo[], folderInnerPath: string): number {
    const prefix = folderInnerPath ? `${folderInnerPath}/` : '';
    const nameSet: Set<string> = new Set();
    for (let i = 0; i < files.length; i++) {
      let path = ArchivePreviewUtil.normalizeInnerPath(files[i].innerFile || '');
      if (!path) {
        continue;
      }
      if (prefix) {
        if (!path.startsWith(prefix)) {
          continue;
        }
        path = path.substring(prefix.length);
      }
      if (!path) {
        continue;
      }
      const slash = path.indexOf('/');
      const name = slash >= 0 ? path.substring(0, slash) : path;
      if (name) {
        nameSet.add(name);
      }
    }
    return nameSet.size;
  }

  /**
   * 将 getArchiveInfo 结果过滤为当前层级的 FileInfo 列表
   */
  public static buildFileListAtLevel(archiveUri: string, files: ArchiveFileInfo[],
    innerPrefix: string): FileInfo[] {
    const prefix = innerPrefix ? (innerPrefix.endsWith('/') ? innerPrefix : `${innerPrefix}/`) : '';
    const nameSet: Set<string> = new Set();
    const result: FileInfo[] = [];

    for (let i = 0; i < files.length; i++) {
      const item = files[i];
      let path = ArchivePreviewUtil.normalizeInnerPath(item.innerFile || '');
      const isDirEntry = item.isDir || (item.innerFile || '').replace(/\\/g, '/').endsWith('/');
      if (!path) {
        continue;
      }
      if (prefix && !path.startsWith(prefix)) {
        continue;
      }
      const rest = prefix ? path.substring(prefix.length) : path;
      if (!rest) {
        continue;
      }
      const slash = rest.indexOf('/');
      const isNested = slash >= 0;
      const name = isNested ? rest.substring(0, slash) : rest;
      if (!name || nameSet.has(name)) {
        continue;
      }
      nameSet.add(name);

      const fullInner = prefix ? `${prefix}${name}` : name;
      const fileInfo = new FileInfo();
      fileInfo.fileName = name;
      fileInfo.relativePath = fullInner;
      fileInfo.uri = `${archiveUri}/${fullInner}`;
      fileInfo.isFolder = isNested || isDirEntry;
      fileInfo.size = isNested ? 0 : Number(item.beforeSize || 0);
      fileInfo.mtime = Number(item.modifyTime || 0);
      if (fileInfo.isFolder) {
        fileInfo.subFileCount = ArchivePreviewUtil.countDirectChildren(files, fullInner);
      }
      fileInfo.mimeTypeObj = FileMimeTypeUtil.getMimeType(name, fileInfo.isFolder, fileInfo.subFileCount);
      fileInfo.mimeType = fileInfo.mimeTypeObj.mimeType;
      FileInfo.getThumbnailType(fileInfo);
      // 包内不做真实缩略图，与「默认类型图标」展示一致
      fileInfo.useCacheImage = false;
      result.push(fileInfo);
    }
    return result;
  }

  /**
   * 文管回到前台时调用：预览结束后清理临时目录（含残留）
   */
  public static onAppForeground(): void {
    const dirs = ArchivePreviewUtil.pendingCleanupDirs.slice();
    ArchivePreviewUtil.pendingCleanupDirs = [];
    if (ArchivePreviewUtil.cleanupTimerId >= 0) {
      clearTimeout(ArchivePreviewUtil.cleanupTimerId);
      ArchivePreviewUtil.cleanupTimerId = -1;
    }
    if (dirs.length === 0) {
      if (ArchivePreviewUtil.cleanupOrphanPreviewDirs() > 0) {
        ArchivePreviewUtil.notifyDownloadUiRefresh();
      }
      return;
    }
    ArchivePreviewUtil.cleanupTimerId = setTimeout(() => {
      ArchivePreviewUtil.cleanupTimerId = -1;
      for (let i = 0; i < dirs.length; i++) {
        ArchivePreviewUtil.removePreviewDir(dirs[i]);
      }
      ArchivePreviewUtil.cleanupOrphanPreviewDirs();
      ArchivePreviewUtil.notifyDownloadUiRefresh();
    }, CLEANUP_DELAY_MS);
  }

  /**
   * 部分解压指定包内文件到公共临时目录后，用第三方应用打开
   */
  public static partDecompressAndOpen(archiveUri: string, innerFile: string, fileName: string,
    password: string = ''): Promise<void> {
    return new Promise((resolve, reject) => {
      const archivePath = FileUtil.getPathFromUri(archiveUri);
      const context = GlobalHolder.getInstance().getMainAbilityContext() ??
        GlobalHolder.getInstance().getUIExtensionContext();
      if (!context || !archivePath) {
        reject(new ArchivePreviewError(StandardErrCode.ERR_UNKNOWN, 'invalid context or archivePath'));
        return;
      }
      // 打开新预览前先清掉上次残留，避免 Download 下堆积
      if (ArchivePreviewUtil.cleanupOrphanPreviewDirs() > 0) {
        ArchivePreviewUtil.notifyDownloadUiRefresh();
      }

      const outDir = `${VirtualUri.DOWNLOAD_PATH}/${PREVIEW_DIR_PREFIX}${Date.now()}`;
      try {
        fs.mkdirSync(outDir, true);
        ArchivePreviewUtil.ensureNoMediaFile(outDir);
      } catch (e) {
        HiLog.warn(TAG, `mkdir preview dir fail: ${JSON.stringify(e)}`);
        reject(new ArchivePreviewError(StandardErrCode.ERR_UNKNOWN, 'mkdir preview dir fail'));
        return;
      }
      const prop = new DeCompressProp();
      prop.inFile = archivePath;
      prop.outDir = outDir;
      prop.innerFiles = [innerFile];
      prop.outName = fileName;
      if (password) {
        prop.password = password;
      }
      const taskKey = `part_decompress_${Date.now()}`;
      try {
        compress.partDeCompress(taskKey, prop, (data: CallbackCompress) => {
          if (data.code === StandardErrCode.ERR_FILEMGR_OK) {
            return;
          }
          if (data.code === StandardErrCode.ERR_COMPRESS_FILE_DECOMPRESS_SUCC) {
            const outPath = `${outDir}/${fileName}`;
            const outUri = ArchivePreviewUtil.buildPublicDocsUri(outPath);
            HiLog.info(TAG, `partDecompress open uri=${outUri}`);
            ArchivePreviewUtil.scheduleCleanup(outDir);
            FileOperation.openFileByOtherApp(outUri, fileName);
            resolve();
            return;
          }
          HiLog.error(TAG, `partDeCompress fail code=${data.code}`);
          ArchivePreviewUtil.removePreviewDir(outDir);
          reject(new ArchivePreviewError(data.code, `partDeCompress code=${data.code}`));
        });
      } catch (e) {
        ArchivePreviewUtil.removePreviewDir(outDir);
        reject(e);
      }
    });
  }

  private static scheduleCleanup(outDir: string): void {
    if (!outDir) {
      return;
    }
    if (ArchivePreviewUtil.pendingCleanupDirs.indexOf(outDir) < 0) {
      ArchivePreviewUtil.pendingCleanupDirs.push(outDir);
    }
  }

  /**
   * 清理 Download 下残留的 .archive_preview_* 目录
   * @returns 实际清理的目录数量
   */
  private static cleanupOrphanPreviewDirs(): number {
    const downloadPath = VirtualUri.DOWNLOAD_PATH;
    let removedCount = 0;
    try {
      if (!fs.accessSync(downloadPath)) {
        return removedCount;
      }
      const names = fs.listFileSync(downloadPath);
      for (let i = 0; i < names.length; i++) {
        const name = names[i];
        if (!name || !name.startsWith(PREVIEW_DIR_PREFIX)) {
          continue;
        }
        // 跳过仍在等待前台清理的目录，避免预览中被误删
        const fullPath = `${downloadPath}/${name}`;
        if (ArchivePreviewUtil.pendingCleanupDirs.indexOf(fullPath) >= 0) {
          continue;
        }
        if (ArchivePreviewUtil.removePreviewDir(fullPath)) {
          removedCount++;
        }
      }
    } catch (e) {
      HiLog.warn(TAG, `cleanupOrphanPreviewDirs fail: ${JSON.stringify(e)}`);
    }
    return removedCount;
  }

  /**
   * 预览临时目录清理后：仅静默刷新 Download 子项计数，不做整页刷新，避免用户看到删临时目录过程
   */
  private static notifyDownloadUiRefresh(): void {
    EventBus.emit(Constant.EVENTS.REFRESH_FOLDER_SUB_FILE_COUNT, VirtualUri.DOWNLOAD);
    HiLog.info(TAG, 'notifyDownloadUiRefresh count only after archive preview cleanup');
  }

  private static ensureNoMediaFile(outDir: string): void {
    try {
      const nomediaPath = `${outDir}/${Constant.NO_MEDIA}`;
      const file = fs.openSync(nomediaPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.closeSync(file);
    } catch (e) {
      HiLog.warn(TAG, `create .nomedia fail: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 将公共路径转为 file://docs URI，避免沙箱 URI 导致图库无法预览
   */
  private static buildPublicDocsUri(filePath: string): string {
    let uri = FileUtil.getUriFromPath(filePath);
    if (uri && uri.startsWith(VirtualUri.URI_HEAD)) {
      return uri;
    }
    if (filePath.startsWith(VirtualUri.LOCAL_PATH_HEAD) || filePath.startsWith('/storage/')) {
      const segments = filePath.split('/');
      let docsPath = '';
      for (let i = 0; i < segments.length; i++) {
        const seg = segments[i];
        if (!seg) {
          continue;
        }
        docsPath += `/${encodeURIComponent(seg)}`;
      }
      uri = `${VirtualUri.URI_HEAD}${docsPath}`;
      HiLog.warn(TAG, `buildPublicDocsUri fallback: ${uri}`);
      return uri;
    }
    return uri;
  }

  private static removePreviewDir(dirPath: string): boolean {
    if (!dirPath || !dirPath.includes(PREVIEW_DIR_PREFIX)) {
      return false;
    }
    try {
      if (!fs.accessSync(dirPath)) {
        return false;
      }
      const names = fs.listFileSync(dirPath);
      for (let i = 0; i < names.length; i++) {
        const childPath = `${dirPath}/${names[i]}`;
        try {
          const stat = fs.statSync(childPath);
          if (stat.isDirectory()) {
            ArchivePreviewUtil.removePreviewDir(childPath);
          } else {
            fs.unlinkSync(childPath);
          }
        } catch (childErr) {
          HiLog.warn(TAG, `remove preview child fail: ${JSON.stringify(childErr)}`);
        }
      }
      fs.rmdirSync(dirPath);
      HiLog.info(TAG, `cleanup preview dir done: ${dirPath}`);
      return true;
    } catch (e) {
      HiLog.warn(TAG, `removePreviewDir fail: ${JSON.stringify(e)}`);
      return false;
    }
  }
}
