/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * 运行时压缩 SDK 桥接：.ets 模块从此处导入 @ohos/oh7zip，避免 .ts 直接引用 ArkTS。
 */

import { compressionKit } from '@ohos/oh7zip';

export const compress = compressionKit;
