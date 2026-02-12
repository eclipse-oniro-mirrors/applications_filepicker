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
import fs from '@ohos.file.fs';
import taskpool from '@ohos.taskpool';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { FileUtil } from '../../fileoperate/FileUtil';
import { BusinessError } from '@kit.BasicServicesKit';

/* instrument ignore file */

/**
 * 递归遍历文件夹下所有层级文件
 */
export class QueryFilesRecursively extends BaseTask {
  constructor(filepath: string, callback: (uris: string[]) => void) {
    super(TaskPoolName.QUERY_FILES_RECURSIVELY);
    this.task = new taskpool.Task(queryFilesRecursively, filepath);
    this.callback = callback;
  }
}


/**
 * 递归遍历目录下所有文件
 */
@Concurrent
async function queryFilesRecursively(filepath: string): Promise<string[]> {
  HiLog.info(TaskPoolName.QUERY_FILES_RECURSIVELY, 'task start');
  if (!filepath) {
    HiLog.info(TaskPoolName.QUERY_FILES_RECURSIVELY, 'filepath empty');
    return [];
  }
  let uris: string[] = [];
  try {
    const filePathList = fs.listFileSync(filepath, { recursion: true });
    uris = filePathList.map<string>(subPath => FileUtil.getUriFromPath(filepath + subPath));
  } catch (e) {
    HiLog.error(TaskPoolName.QUERY_FILES_RECURSIVELY, `queryFilesRecursively error: ${(e as BusinessError).code}`);
  }
  return uris;
}