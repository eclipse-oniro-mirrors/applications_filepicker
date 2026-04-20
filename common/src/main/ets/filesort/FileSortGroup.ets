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

// 名称分组
export const GROUP_NAME_BY_NAME_LIST: string [] =
  ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
    'W', 'X', 'Y', 'Z'];

// 大小分组
export const GROUP_NAME_BY_SIZE_LIST: ResourceStr [] =
  [$r('app.string.hidisk_file_size_range_smaller_kb', 1),
    '1 KB - 1 MB', '1 MB - 10 MB', '10 MB - 100 MB', '100 MB - 1 GB',
    $r('app.string.hidisk_file_size_range_larger_gb', 1)];

// 类型分组
export const GROUP_NAME_BY_DISPLAY_LIST: ResourceStr [] =
  [$r('app.string.other'),
    'PNG', 'JPEG', 'JPG', 'GIF', 'BMP', 'TIF', 'WEBP', 'HEIF', 'PSD', 'RAW', // 图片
    'MP4', 'MPG', 'AVI', 'MOV', 'FLV', 'WMV', 'RMVB', '3GP', '3GPP', 'M4U', 'M4V', 'F4V', 'MKV', 'WEBM', '3GPP2', 'MPE',
    'MPEG', 'MPEG4', // 视频
    'DOC', 'DOCX', 'DOCM', 'DOT', 'DOTX', 'DOTM', 'PPT', 'PPTX', 'PPTM', 'POT', 'POTX', 'PPS', 'PPSX', 'XLS', 'XLSX',
    'XLSM', 'CSV', 'XLT', 'XLTX', 'PDF', 'TXT', 'TXET', 'EPUB', 'HTM', 'HTML', // 文档
    'ZIP', 'RAR', 'TAR', '7Z', // 压缩包
    'MP3', 'MAV', 'AAC', 'FLAC', 'AMR', 'M4A', 'MPGA', 'MXMF', 'MID', 'MIDI', 'RTTTL', 'RTX', 'XMF', 'SMF', 'IMY', 'MGG', 'MFLAC'// 音频
  ]