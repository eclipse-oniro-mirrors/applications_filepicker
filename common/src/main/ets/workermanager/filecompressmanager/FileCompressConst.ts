/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023. All rights reserved.
 */
import WorkerConst from '../../worker/WorkerConst';
import { PathLocation } from '../../const/HiSysEventConst';
import { StandardErrCode } from './CompressStandardErrCode';

// @KeepSymbol
export namespace FileCompressConst {
  /* 任务类型分类 */
  export enum TaskType {
    COMPRESS = 'COMPRESS',
    DECOMPRESS = 'DECOMPRESS',
    CANCEL = 'CANCEL'
  }

  export const DIALOG_ERROR_TITLE_MAP = new Map([
    [TaskType.COMPRESS, $r('app.string.compression_failed')],
    [TaskType.DECOMPRESS, $r('app.string.decompression_failed')],
  ]);

  export const DIALOG_ERROR_MESSAGE_MAP = new Map([
    [StandardErrCode.ERR_NO_SPACE, $r('app.string.compress_insufficient_disk_space')],
    [StandardErrCode.ERR_COMPRESS_ARCHIVE_EXCEPT, $r('app.string.archive_except')],
    [StandardErrCode.ERR_COMPRESS_ARCHIVE_VOLUME, $r('app.string.volume_file_preview_fail')],
    [StandardErrCode.ERR_COMPRESS_FILE_COMPRESS_FAILED, $r('app.string.compress_fail')],
    [StandardErrCode.ERR_COMPRESS_FILE_DECOMPRESS_FAILED, $r('app.string.decompress_fail')],
    [StandardErrCode.ERR_COMPRESS_PASSWORD_VERIFY_FAILED, $r('app.string.password_error')],
    [StandardErrCode.ERR_FILE_NAME_DUPLICATED, $r('app.string.compress_exist_duplicate_file')],
  ]);
}

export default FileCompressConst;