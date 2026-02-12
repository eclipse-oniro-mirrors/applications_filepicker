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
import { Constant } from './Constant';

export namespace FileTagConst {
  export const TAG_VIRTUAL_URI_HEAD = 'tag://';

  export const ALL_TAG_VIRTUAL_URI_HEAD = 'allTag://';

  export const MAX_SIDE_BAR_TAG_NUM = 100;

  export const MAX_TAG_NAME_LENGTH = 127;

  export const MAX_TAG_NUM = 1000;

  export const MAX_TAG_NUM_ON_FILE = 7;

  export const MAX_DEFAULT_TAG_NUM = 7;

  export const DEFAULT_TAG_FILE_NAME = 'default_tag';

  export const DEFAULT_TAG_PATH =
    `${Constant.MY_PC_PATH_HEAD}/${Constant.THUMBS_FOLDER}/${FileTagConst.DEFAULT_TAG_FILE_NAME}`;

  export const TAG_DB_DIR = 'rdb';
}