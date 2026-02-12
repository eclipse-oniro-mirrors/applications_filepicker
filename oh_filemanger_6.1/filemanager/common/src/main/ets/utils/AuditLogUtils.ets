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
import { fileIo as fs, WriteOptions } from '@kit.CoreFileKit';
import { zlib } from '@kit.BasicServicesKit';
import { HiLog } from '../dfx/HiLog';
import { Constant } from '../const/Constant';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { FsUtil } from './FsUtil';
import { maskString } from './StringUtil';


/**
 * 1、确定写的路径, hap写到共享内存/data/storage/el2/log/audit
 * 2、创建 x个log文件, 一个写满, 再写另一个, 依次循环交替写
 * 3、应用写审计日志时, 可能存在1200条/s极限速度, 可以先缓存到某个列表里, 满了后再写到文件里
 * 4、落盘的日志是.csv格式, 内容是按字段写, 以逗号区分, 便于后续的展示
 * 5、限制条件：写到缓存string最大1200条; 一个应用日志限额总默认10M, 2个文件; 每条数据平均200~300字节;
 * 6、文件满后重命名, 然后压缩
 */

/**
 * 增删改操作类型
 */
export enum OperationType {
  OPERATION_DELETE = 'DEL',
  OPERATION_ADD = 'ADD',
  OPERATION_MOVE = 'MOV',
  OPERATION_RENAME = 'RNAME',
  OPERATION_COPY = 'CP'
}

const TAG = 'AuditLogUtils';
const ONE_DIGITS = 10;
const TWO_DIGITS = 100;
const BATCH_SIZE = 100;

export class AuditLogUtils {
  private static readonly MAX_SINGLE_FILE_LOG_SIZE = 3 * 1024 * 1024; // 一个日志文件最大限额3M, 存满则进行压缩(约10:1压缩比)
  private static readonly MAX_AUDIT_LOG_SIZE = 2 * 1024; // 一条审计日志最大为 2kb
  private static readonly MAX_LOG_FILE_COUNT = 10; // 落盘日志文件个数, 10个300k约3M

  private static readonly LOG_PATH_DIR_SANDBOX = '/data/storage/el2/log/audit'; // hap 日志落盘路径

  // 需应用修改
  private static readonly LOG_NAME = 'filemanager'; //落盘日志文件名称
  private static readonly LOG_PATH_DIR = AuditLogUtils.LOG_PATH_DIR_SANDBOX; //hap用沙箱
  private static readonly LOG_FILE_PATH = AuditLogUtils.LOG_PATH_DIR + '/' + AuditLogUtils.LOG_NAME + '_audit.csv';
  private static instance: AuditLogUtils;

  private constructor() {
    this.mkdirSync(AuditLogUtils.LOG_PATH_DIR);
  }

  public static getInstance(): AuditLogUtils {
    if (!AuditLogUtils.instance) {
      AuditLogUtils.instance = new AuditLogUtils();
    }
    return AuditLogUtils.instance;
  }

  public batchWriteAudit(uris : string[], cause: string) {
    if (!uris || uris.length === 0) {
      return;
    }
    const length = uris.length;
    for (let i = 0; i < length; i += BATCH_SIZE) {
      const tempArray = uris.slice(i, i + BATCH_SIZE);
      const fileNames = tempArray.map(it => maskString(it)).join('|');
      this.writeAudit('', fileNames, cause, -1);
    }
  }

  public writeAudit(filePath: string, fileName: string, cause: string, fileCreateTime: number) {
    try {
      this.writeAuditEvent(
        {
          happenTime: new Date().toISOString(),
          packageName: Constant.FILE_MANAGER_BUNDLE_NAME,
          isForeground: true,
          isUserBehavior: true,
          cause: cause,
          operationType: OperationType.OPERATION_DELETE,
          operationCount: 1,
          operationStatus: 'success',
          extend: '',
          fileType: FileMimeTypeUtil.getFileMimeType(fileName).mimeType,
          filePath: filePath,
          fileTargetPath: '',
          fileName: fileName,
          fileCreateTime: String(fileCreateTime),
          fileSize: -1,
        } as FileAuditLog
      )
    } catch (err) {
      HiLog.error(TAG, `writeAuditEvent error: ${err}`);
    }
  }

  /**
   * 写单条审计日志
   * @param 字段封装类AuditLog
   * @returns true 为写成功
   */
  private writeAuditEvent(log: AuditLog): boolean {
    if (!log) {
      HiLog.error(TAG, 'audit log is null.');
      return false;
    }

    let auditLogs: string = '';
    let fileSize: number = FsUtil.getFileSizeSyncByPath(AuditLogUtils.LOG_FILE_PATH);
    if (fileSize === 0) {
      auditLogs = this.getAuditLogKeys(log); // 写title 字段
    }
    auditLogs += this.getAuditLogValues(log); // 日志转化成文本

    // 如果文件满了, 写不下, 需要另存为1个文件, 清空再写新的
    if (((fileSize + auditLogs.length) >= AuditLogUtils.MAX_SINGLE_FILE_LOG_SIZE)) {
      let time: string = AuditLogUtils.getFormatTime();
      let dstFilePath = AuditLogUtils.LOG_PATH_DIR + '/' + AuditLogUtils.LOG_NAME + '_audit_' + time;
      this.cleanUpLogFilePath(AuditLogUtils.LOG_FILE_PATH, dstFilePath, AuditLogUtils.LOG_PATH_DIR);

      fileSize = 0; // 文件清空, 重建一个
      auditLogs = this.getAuditLogKeys(log) + auditLogs; // 文件满了后, 新写文件需要把title也写上
    }

    let writeLen = this.writeToFile(AuditLogUtils.LOG_FILE_PATH, auditLogs);
    return writeLen > 0;
  }

  private writeToFile(filePath: string, logStr: string): number {
    let writeLen = 0;
    let file: fs.File | null = null;

    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let size: number = FsUtil.getFileSizeSyncByPath(filePath);
      let options: WriteOptions = { offset: size, encoding: 'utf-8' };
      writeLen = fs.writeSync(file.fd, logStr, options);
    } catch (e) {
      HiLog.error(TAG, `writrToFile error: code: ${e?.code} message ${e?.message} `);
    } finally {
      if (file != null) {
        fs.closeSync(file);
      }
    }
    return writeLen;
  }

  /**
   * 文件写满, 重命名新文件, 个数达到上限时老化最早的一个文件
   * @param srcFilePath
   * @param dstFilePath
   * @param logFileDir
   */
  private cleanUpLogFilePath(srcFilePath: string, dstFilePath: string, logFileDir: string): void {
    try {
      let tmpFilePath: string = dstFilePath + '.csv';
      // 重命名文件
      fs.renameSync(srcFilePath, tmpFilePath);
      // 异步把已满文件压缩File
      this.zipFile(tmpFilePath, dstFilePath + '.zip').then(
        () => {
          // 压缩完把原来文件删除
          fs.unlink(tmpFilePath);
        }
      );

      let logFileList = this.getFileListByOrder(logFileDir);
      while (logFileList.length >= AuditLogUtils.MAX_LOG_FILE_COUNT) {
        let oldestFile = logFileList.pop();
        fs.unlinkSync(oldestFile);
      }

    } catch (e) {
      HiLog.error(TAG, `renameSync or cleanOldestFile error: ${e?.message}`);
    }
  }

  private mkdirSync(dirPath: string): boolean {
    if (this.isFileExist(dirPath) && FsUtil.isFolder(dirPath) === true) {
      return true;
    }

    try {
      fs.mkdirSync(dirPath);
      return true;
    } catch (e) {
      HiLog.error(TAG, `mkdirSync error: ${e?.message}`);
      return false;
    }
  }

  private isFileExist(filePath: string): boolean {
    let isFileExist: boolean = false;
    try {
      isFileExist = fs.accessSync(filePath);
    } catch (e) {
      HiLog.error(TAG, `file not exist: '${e.code}, ${e.message}`);
    }
    return isFileExist;
  }

  private isFile(filePath: string): boolean {
    let isFile: boolean = false;
    if (this.isFileExist(filePath)) {
      try {
        isFile = fs.statSync(filePath).isFile();
      } catch (e) {
        HiLog.error(TAG, `'isFile error:'${e.code}, ${e.message}`);
      }
    }
    return isFile;
  }

  private getFileLastModifyTime(filePath: string): number {
    let time: number = 0;

    try {
      time = fs.statSync(filePath).mtime;
    } catch (e) {
      HiLog.error(TAG, `getFileLastModifyTime error: ${e?.message}`);
    }
    return time;
  }

  private getFilesInDir(dirPath: string, recursive: boolean = false, relativePath: boolean = false): string[] {
    let result: string[] = [];
    if (FsUtil.isFolder(dirPath) !== true) {
      HiLog.infoPrivate(TAG, `getFilesInDir not dir:`, dirPath);
      return result;
    }

    let fileList: string[] = [];
    try {
      fileList = fs.listFileSync(dirPath, {
        recursion: recursive
      }).filter(file => this.isFile(`${dirPath}/${file}`));
      if (relativePath) {
        return fileList;
      }
    } catch (e) {
      HiLog.info(TAG, `get files error: ${e.code}, ${e.message}`);
      return result;
    }

    for (let fileName of fileList) {
      let filePath = `${dirPath}/${fileName}`;
      result.push(filePath);
    }

    return result;
  }

  private getFileListByOrder(dirPath: string): string[] {
    let fileList: string[] =
      this.getFilesInDir(dirPath).filter((logPath) => logPath.includes('_audit_') && logPath.includes('.zip'));
    if (fileList.length > 1) {
      fileList.sort((file1, file2) => this.getFileLastModifyTime(file2) - this.getFileLastModifyTime(file1));
    }
    return fileList;
  }

  /**
   * 将日志内容由 AuditLog封装类转换成以逗号相隔的字符串
   * @param obj
   * @returns
   */
  private getAuditLogValues(obj: AuditLog): string {
    let auditLog = Object.values(obj).join(', ') + '\n';
    if (auditLog.length >= AuditLogUtils.MAX_AUDIT_LOG_SIZE) {
      // 单条日志大于2kb则截断
      auditLog = auditLog.substring(0, AuditLogUtils.MAX_AUDIT_LOG_SIZE) + '\n';
      HiLog.error(TAG, `The log size exceeds 2 KB, length: ${auditLog.length}`);
    }
    return auditLog;
  }

  /**
   * 日志文件首行title字段
   * @param obj
   * @returns
   */
  private getAuditLogKeys(obj: AuditLog): string {
    return Object.keys(obj).join(', ') + '\n';
  }

  private async zipFile(srcPath: string, zipPath: string): Promise<boolean> {
    if (!this.isFileExist(srcPath)) {
      return false;
    }
    let options: zlib.Options = {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
      memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
      strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
    };

    try {
      let errData = await zlib.compressFile(srcPath, zipPath, options);
      if (errData != null) {
        HiLog.errorPrivate(TAG, 'zip file error:', `${srcPath}, ${JSON.stringify(errData)}`);
        return false;
      }
      HiLog.infoPrivate(TAG, 'zip file success:', `${srcPath.substring(srcPath.lastIndexOf('/') + 1, srcPath.length)}`);
      return true;
    } catch (errData) {
      HiLog.errorPrivate(TAG, `errData is errCode:${errData.code}  message:${errData.message}`, srcPath);
    }
    return false;
  }

  /**
   * 格式化时间 from yyyy-MM-dd HH:mm:ss:SSS to yyyyMMddHHmmssSSS
   * @returns
   */
  public static getFormatTime(): string {
    let date = new Date();
    let time = date.getFullYear().toString() + AuditLogUtils.addZero(date.getMonth() + 1) +
    AuditLogUtils.addZero(date.getDate()) + AuditLogUtils.addZero(date.getHours()) +
    AuditLogUtils.addZero(date.getMinutes()) + AuditLogUtils.addZero(date.getSeconds()) +
    AuditLogUtils.addZero(date.getMilliseconds(), true);
    return time;
  }

  /**
   * 格式化数字
   * @param base
   * @param flag
   * @returns
   */
  private static addZero(base: number, flag?: boolean): string {
    if (!flag && base < ONE_DIGITS) {
      return `0${base}`;
    } else if (flag && base < ONE_DIGITS) {
      return `00${base}`;
    } else if (flag && base < TWO_DIGITS) {
      return `0${base}`;
    } else {
      return base.toString();
    }
  }
}

/**
 * 日志字段封装类
 */
export interface AuditLog {
  happenTime: string;
  packageName: string;
  isForeground: boolean;
  isUserBehavior: boolean;
  cause: string;
  operationType: string;
  operationScenario: string;
  operationCount: number;
  operationStatus: string;
  extend: string;
}

/**
 * 实体文件日志字段封装类
 */
export interface FileAuditLog extends AuditLog {
  fileType: string;
  filePath: string;
  fileTargetPath: string;
  fileName: string;
  fileCreateTime: string;
  fileSize: number;
}

/**
 * 数据库数据等日志字段封装类
 */
export interface DataAuditLog extends AuditLog {
  dbStatus: string;
  hwidStatus: string;
}