/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * 运行时压缩 SDK 桥接：.ets 模块从此处导入 @ohos/oh7zip，避免 .ts 直接引用 ArkTS。
 * TODO: oh7zip 上库后恢复真实 import
 */

// import { compressionKit } from '@ohos/oh7zip';

const ERR_COMPRESS_FAILED = 1014001020;
const ERR_DECOMPRESS_FAILED = 1014001021;

export const compress = {
  compression: (_taskKey: string, _prop: object, callback: Function): void => {
    callback({ code: ERR_COMPRESS_FAILED, progress: 0, file: '' });
  },
  deCompression: (_taskKey: string, _prop: object, callback: Function): void => {
    callback({ code: ERR_DECOMPRESS_FAILED, progress: 0, file: '' });
  },
  cancel: (_taskKey: string): number => 0,
  getArchiveInfo: (_taskKey: string, _prop: object, callback: Function): void => {
    callback({ code: ERR_DECOMPRESS_FAILED, files: [], beforeSize: 0, afterSize: 0, filesNum: 0, foldersNum: 0 });
  },
  partDeCompress: (_taskKey: string, _prop: object, callback: Function): void => {
    callback({ code: ERR_DECOMPRESS_FAILED, progress: 0, file: '' });
  },
  addCompress: (_taskKey: string, _prop: object, callback: Function): void => {
    callback({ code: ERR_COMPRESS_FAILED, progress: 0, file: '' });
  },
  isCompressEncryptedSync: (_inFile: string): boolean => false,
  isCompressEncrypted: (_inFile: string): Promise<boolean> => Promise.resolve(false),
};
