/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import type { Callback } from '@ohos.base';

// @ts-ignore
// @KeepSymbol
declare namespace compress {
  /**
   * Defines standard error codes.
   *
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  enum StandardErrCode {
    ERR_FILEMGR_OK = 0,
    ERR_PERMISSION_DENIED = 201,
    ERR_NOT_SYSTEM_APP = 202,
    ERR_PERM = 1014000001,
    ERR_NOENT = 1014000002,
    ERR_NO_SPACE = 1014000003,
    ERR_INNER_ERROR = 1014000004,
    ERR_INVALID_SHORTCUT = 1014000005,
    ERR_FILEMGR_ERR = 1014000006,
    ERR_CANCEL = 1014000007,
    ERR_PARAM_NUMBER_MISMATCH = 1014000008,
    ERR_PARAM_IS_EMPTY = 1014000009,
    ERR_PARAM_TYPE_MISMATCH = 1014000010,
    ERR_PARAM_INVALID = 1014000011,
    ERR_FILE_FILE_NOT_EXIST = 1014000012,
    ERR_FILE_DIR_NOT_EXIST = 1014000013,
    ERR_FILE_ALREADY_EXIST = 1014000014,
    ERR_FILE_READ_FILE_FAILED = 1014000015,
    ERR_FILE_WRITE_FILE_FAILED = 1014000016,
    ERR_MKDIR_FAILED = 1014000017,
    ERR_INVALID_PATH = 1014000018,
    ERR_IPC_READ = 1014000019,
    ERR_IPC_WRITE = 1014000020,
    ERR_DB_GET_INSTANCE_FAIL = 1014000021,
    ERR_DB_OPERATE_FAIL = 1014000022,
    ERR_QUANTITY_REACH_THE_LIMIT = 1014000023,
    ERR_FILE_NAME_DUPLICATED = 1014000101,
    ERR_COMPRESSION_ARCHIVE_DAMAGED = 1014000102,
    ERR_UNSUPPORTED_FORMAT = 1014000103,
    ERR_UNKNOWN = 1014000999,
    ERR_COMPRESS_ARCHIVE_EXCEPT = 1014001006,
    ERR_COMPRESS_ARCHIVE_VOLUME = 1014001007,
    ERR_COMPRESS_PASSWORD_NULL = 1014001008,
    ERR_COMPRESS_PASSWORD_VERIFY_FAILED = 1014001009,
    ERR_COMPRESS_FILE_NAME_ENCRYPTED = 1014001010,
    ERR_COMPRESS_FILE_NAME_TOO_LONG = 1014001011,
    ERR_COMPRESS_FILE_NAME_TOO_LONG_TRUNCATED = 1014001012,
    ERR_COMPRESS_FAILED_FULL_PATH_TOO_LONG = 1014001013,
    ERR_COMPRESS_PREVIEW_ARCHIVE_SUCC = 1014001014,
    ERR_COMPRESS_FILE_COMPRESS_SUCC = 1014001015,
    ERR_COMPRESS_FILE_DECOMPRESS_SUCC = 1014001016,
    ERR_COMPRESS_CANCEL_FILE_COMPRESS_SUCC = 1014001017,
    ERR_COMPRESS_CANCEL_FILE_DECOMPRESS_SUCC = 1014001018,
    ERR_COMPRESS_PREVIEW_ARCHIVE_FAILED = 1014001019,
    ERR_COMPRESS_FILE_COMPRESS_FAILED = 1014001020,
    ERR_COMPRESS_FILE_DECOMPRESS_FAILED = 1014001021,
    ERR_TRASH_CAN_NOT_RECOVER_CLOUD_FILE_TO_LOCAL = 1014003007,
    ERR_SHORTCUT_SUFFIX_MISMATCH = 1014006009,
    ERR_THUMBNAIL_IMAGE_SIZE_EXCEEDS_LIMIT = 1014008005,
    ERR_THUMBNAIL_IMAGE_LOAD_FAIL = 1014008006,
    ERR_THUMBNAIL_QUERY_METADATA = 1014008010,
    ERR_THUMBNAIL_QUERY_ROTATE = 1014008011,
  }

  /**
   * Defines compression information.
   *
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  interface CompressInfo {
    /**
     * Sandbox path set of the files to be compressed.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    inputFiles: Array<string>;

    /**
     * Sandbox path of the generated package.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    outputFile: string;

    /**
     * Format of the generated package.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    format?: CompressionFormat;
  }

  /**
   * Defines the supported package types.
   *
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  enum CompressionFormat {
    /**
     * ZIP format.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    FORMAT_ZIP = 0,

    /**
     * 7Z format.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    FORMAT_7Z = 1,

    /**
     * GZIP format.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    FORMAT_GZIP = 2
  }

  /**
   * Defines decompression information.
   *
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  interface DecompressInfo {
    /**
     * Sandbox path of the package to be decompressed.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    inputFile: string;

    /**
     * Sandbox path of the folders generated after package decompression.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    outputDir: string;
  }

  /**
   * Defines the progress of a compression or decompression task.
   *
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  interface CompressionTask {
    /**
     * error code
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    code: number;

    /**
     * Compression or decompression progress. The value range is [0, 100]. The value **100** indicates that the
     * compression or decompression is complete.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @since 5.1.1(19)
     */
    progress: number;
  }

  /**
   * Compresses a file or folder.
   *
   * @param { CompressInfo } compressInfo - Compression information.
   * @param { Callback<CompressionTask> } callback - Callback function used to return the compression progress.
   * @throws { BusinessError } 202 - Non-system applications are not allowed to use system APIs.
   * @throws { BusinessError } 1014000001 - Operation not permitted.
   * @throws { BusinessError } 1014000002 - No such file or directory.
   * @throws { BusinessError } 1014000003 - No space left on device.
   * @throws { BusinessError } 1014000101 - Exist duplicate file name.
   * @throws { BusinessError } 1014000103 - Unsupported format.
   * @throws { BusinessError } 1014000999 - Unknown error.
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  function compress(compressInfo: CompressInfo, callback: Callback<CompressionTask>): void;

  /**
   * Decompresses a file.
   *
   * @param { DecompressInfo } decompressInfo - Decompression information.
   * @param { Callback<CompressionTask> } callback - Callback function used to return the decompression progress.
   * @throws { BusinessError } 202 - Non-system applications are not allowed to use system APIs.
   * @throws { BusinessError } 1014000001 - Operation not permitted.
   * @throws { BusinessError } 1014000002 - No such file or directory.
   * @throws { BusinessError } 1014000003 - No space left on device.
   * @throws { BusinessError } 1014000102 - Archive is damaged.
   * @throws { BusinessError } 1014000103 - Unsupported format.
   * @throws { BusinessError } 1014000999 - Unknown error.
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @since 5.1.1(19)
   */
  function decompress(decompressInfo: DecompressInfo, callback: Callback<CompressionTask>): void;

  /**
   * dir file item
   *
   * @interface DirFileItem
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface DirFileItem {
    /**
     * dir path
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    dirPath: string;

    /**
     * files to be compressed in dir
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    inFiles: string[];
  }

  /**
   * Compress properties.
   *
   * @interface CompressProp
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface CompressProp {
    /**
     * Files to be compressed
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    inFiles: string[];

    /**
     * dir file items
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    dirFiles?: DirFileItem[];

    /**
     * Directory in the archive
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    innerDir?: string;

    /**
     * Full path of the generated archive (contain file name)
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    outFile: string;

    /**
     * Compressed Password if needed
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    password?: string;

    /**
     * Compressed Format. Currently only .zip is supported
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    archiveFormat?: string;

    /**
     * compression algorithm
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    algorithms?: string;

    /**
     * Compression Level (0,1,3,5,7,9)
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    compressionLevel?: number;

    /**
     * volumes size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    volumeSize?: number;
  }

  /**
   * Callback compress.
   *
   * @interface CallbackCompress
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface CallbackCompress {
    /**
     * error code
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    code: number;

    /**
     * progress
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    progress: number;

    /**
     * file name
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    file: string;
  }

  /**
   * Decompress properties.
   *
   * @interface DeCompressProp
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface DeCompressProp {
    /**
     * Archive file to be decompressed.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    inFile: string;

    /**
     * Relative path of files in the archive.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    innerFiles?: string[];

    /**
     * Password to decompress if needed.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    password?: string;

    /**
     * Output directory.
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    outDir: string;

    /**
     * Output name file, Only single-file decompression and renaming for partial decompression
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    outName?: string;
  }

  /**
   * Get archive info properties.
   *
   * @interface GetArchiveInfoProp
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface GetArchiveInfoProp {
    /**
     * Archive file to get info
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    inFile: string;

    /**
     * Password to GetArchiveInfo for file name encrypted archive
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    password?: string;
  }

  /**
   * Archive file info.
   *
   * @interface ArchiveFileInfo
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface ArchiveFileInfo {
    /**
     * file name
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    innerFile: string;

    /**
     * compress before size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    beforeSize: number;

    /**
     * compress after size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    afterSize: number;

    /**
     * is folder
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    isDir: boolean;

    /**
     * is encrypted
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    isEncrypted: boolean;

    /**
     * modify time
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    modifyTime: number;

    /**
     * file hash value
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    fileHash: string;
  }

  /**
   * Archive info.
   *
   * @interface ArchiveInfo
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface ArchiveInfo {
    /**
     * file list
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    files: ArchiveFileInfo[];

    /**
     * compress before size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    beforeSize: number;

    /**
     * compress after size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    afterSize: number;

    /**
     * file count
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    filesNum: number;

    /**
     * folder count
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    foldersNum: number;
  }

  /**
   * Callback archive info.
   *
   * @interface CallbackArchiveInfo
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  interface CallbackArchiveInfo {
    /**
     * error code
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    code: number;

    /**
     * file list
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    files: ArchiveFileInfo[];

    /**
     * compress before size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    beforeSize: number;

    /**
     * compress after size
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    afterSize: number;

    /**
     * file count
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    filesNum: number;

    /**
     * folder count
     *
     * @syscap SystemCapability.FileManagement.FileManagerService.Core
     * @systemapi
     * @stagemodelonly
     * @since 26.0.0
     */
    foldersNum: number;
  }

  /**
   * Compress files.
   *
   * @param { string } taskKey - task unique value
   * @param { CompressProp } prop - compress properties
   * @param { Callback<CallbackCompress> } callback - callback function
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000003 - no space left on device
   * @throws { BusinessError } 1014000006 - generic error
   * @throws { BusinessError } 1014000007 - file compression canceled successfully
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014000101 - exist duplicate file name
   * @throws { BusinessError } 1014001006 - the decompressing package is exception
   * @throws { BusinessError } 1014001007 - the decompressing package is volume
   * @throws { BusinessError } 1014001008 - the password is null
   * @throws { BusinessError } 1014001009 - failed to verify the password
   * @throws { BusinessError } 1014001011 - failed to decompress files of too long names
   * @throws { BusinessError } 1014001015 - compress files success
   * @throws { BusinessError } 1014001017 - cancel file compress success
   * @throws { BusinessError } 1014001020 - compress files failed
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function compression(taskKey: string, prop: CompressProp, callback: Callback<CallbackCompress>): void;

  /**
   * Decompress files.
   *
   * @param { string } taskKey - task unique value
   * @param { DeCompressProp } prop - decompress properties
   * @param { Callback<CallbackCompress> } callback - callback function
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000003 - no space left on device
   * @throws { BusinessError } 1014000006 - generic error
   * @throws { BusinessError } 1014000007 - file decompression canceled successfully
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014001006 - the decompressing package is exception
   * @throws { BusinessError } 1014001007 - the decompressing package is volume
   * @throws { BusinessError } 1014001008 - the password is null
   * @throws { BusinessError } 1014001009 - failed to verify the password
   * @throws { BusinessError } 1014001010 - file name encrypted
   * @throws { BusinessError } 1014001011 - failed to decompress files of too long names
   * @throws { BusinessError } 1014001012 - decompress files success but auto truncate long name
   * @throws { BusinessError } 1014001013 - decompress files fail. auto truncate long name but still long
   * @throws { BusinessError } 1014001016 - decompress files success
   * @throws { BusinessError } 1014001018 - cancel file decompress success
   * @throws { BusinessError } 1014001021 - decompress files failed
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function deCompression(taskKey: string, prop: DeCompressProp,
    callback: Callback<CallbackCompress>): void;

  /**
   * Add files to the archive.
   *
   * @param { string } taskKey - task unique value
   * @param { CompressProp } prop - compress properties
   * @param { Callback<CallbackCompress> } callback - callback function
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000003 - no space left on device
   * @throws { BusinessError } 1014000006 - generic error
   * @throws { BusinessError } 1014000007 - file compression canceled successfully
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014000101 - exist duplicate file name
   * @throws { BusinessError } 1014001008 - the password is null
   * @throws { BusinessError } 1014001009 - failed to verify the password
   * @throws { BusinessError } 1014001011 - failed to decompress files of too long names
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function addCompress(taskKey: string, prop: CompressProp, callback: Callback<CallbackCompress>): void;

  /**
   * Partial file decompression and preview.
   *
   * @param { string } taskKey - task unique value
   * @param { DeCompressProp } prop - decompress properties
   * @param { Callback<CallbackCompress> } callback - callback function
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000003 - no space left on device
   * @throws { BusinessError } 1014000006 - generic error
   * @throws { BusinessError } 1014000007 - file decompression canceled successfully
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014001006 - the decompressing package is exception
   * @throws { BusinessError } 1014001007 - the decompressing package is volume
   * @throws { BusinessError } 1014001008 - the password is null
   * @throws { BusinessError } 1014001009 - failed to verify the password
   * @throws { BusinessError } 1014001010 - file name encrypted
   * @throws { BusinessError } 1014001011 - failed to decompress files of too long names
   * @throws { BusinessError } 1014001012 - decompress files success but auto truncate long name
   * @throws { BusinessError } 1014001013 - decompress files fail. auto truncate long name but still long
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function partDeCompress(taskKey: string, prop: DeCompressProp,
    callback: Callback<CallbackCompress>): void;

  /**
   * Synchronously determine if the compressed file is encrypted.
   *
   * @param { string } inFile - compressed file full path
   * @returns { boolean } whether the compressed file is encrypted, true-encrypted, false-not encrypted
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function isCompressEncryptedSync(inFile: string): boolean;

  /**
   * Asynchronously determine if the compressed file is encrypted.
   *
   * @param { string } inFile - compressed file full path
   * @returns { Promise<boolean> } whether the compressed file is encrypted, true-encrypted, false-not encrypted
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function isCompressEncrypted(inFile: string): Promise<boolean>;

  /**
   * Cancel task.
   *
   * @param { string } taskKey - task unique value
   * @returns { number } cancel result error code
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014001017 - cancel file compress success
   * @throws { BusinessError } 1014001018 - cancel file decompress success
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function cancel(taskKey: string): number;

  /**
   * Get compressed file information.
   *
   * @param { string } taskKey - task unique value
   * @param { GetArchiveInfoProp } prop - compressed file properties
   * @param { Callback<CallbackArchiveInfo> } callback - callback function
   * @throws { BusinessError } 202 - system API is not allowed called by Non-system application.
   * @throws { BusinessError } 1014000006 - generic error
   * @throws { BusinessError } 1014000008 - parameter number mismatch
   * @throws { BusinessError } 1014000010 - parameter type mismatch
   * @throws { BusinessError } 1014001006 - the decompressing package is exception
   * @throws { BusinessError } 1014001007 - the decompressing package is volume
   * @throws { BusinessError } 1014001008 - the password is null
   * @throws { BusinessError } 1014001009 - failed to verify the password
   * @throws { BusinessError } 1014001010 - file name encrypted
   * @throws { BusinessError } 1014001019 - preview archive failed
   * @syscap SystemCapability.FileManagement.FileManagerService.Core
   * @systemapi
   * @stagemodelonly
   * @since 26.0.0
   */
  function getArchiveInfo(taskKey: string, prop: GetArchiveInfoProp, callback: Callback<CallbackArchiveInfo>): void;
}