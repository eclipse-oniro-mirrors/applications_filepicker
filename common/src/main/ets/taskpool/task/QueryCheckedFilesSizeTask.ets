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

import taskpool from '@ohos.taskpool';
import { FileUtil } from '../../fileoperate/FileUtil';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName, TaskConst } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { FileInfo } from '../../fileoperate/FileInfo';
import { VirtualUri } from '../../const/FolderRecord';
import { Constant } from '../../const/Constant';
import { common } from '@kit.AbilityKit';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';
import { PageUtil } from '../../utils/PageUtil';

/* instrument ignore file */

/**
 * 查询文件夹项数常量
 */
export class QueryCheckedFilesSizeTask extends BaseTask {
  constructor(checkedFiles: FileInfo[], ctx: common.ServiceExtensionContext, callback: Function) {
    super(TaskPoolName.QUERY_CHECKED_FILE_SIZE);
    this.task = new taskpool.Task(startTask, checkedFiles, ctx);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri uri
 * @returns 文件夹大小
 */
@Concurrent
async function startTask(checkedFiles: FileInfo[], ctx: common.ServiceExtensionContext): Promise<number> {
  try {
    let resSize: number = 0;
    for (const f of checkedFiles) {
      if (f.isFolder) {
        if (FileUtil.isGalleryAddress(f.uri)) {
          const size = await PhotoAccessUtil.getAlbumSize(ctx, f);
          resSize += size;
        } else {
          if (f.relativePath === VirtualUri.LOCAL_PATH_HEAD) {
            let totalSize = await PageUtil.getLocalTotalSpace();
            let freeSize = await PageUtil.getLocalFreeSpace();
            resSize = totalSize - freeSize;
          } else {
            let fileUri = f.uri;
            if (FileUtil.isBundleNameInDownloadDir(fileUri)) {
              fileUri = FileUtil.getDownloadPathByBundleName(f.uri);
            }
            const size = await FileUtil.getFolderSizeByFs(fileUri);
            resSize += size;
          }
        }
      } else {
        resSize += f.size;
      }
    }
    return resSize;
  } catch (error) {
    HiLog.error(TaskConst.TAG, `QueryCheckedFilesSizeTask fail, error: ${JSON.stringify(error)}`);
    return 0;
  }
}


