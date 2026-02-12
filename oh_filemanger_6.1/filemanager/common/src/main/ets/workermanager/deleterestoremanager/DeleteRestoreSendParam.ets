/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import type { FileInfo } from '../../fileoperate/FileInfo';
import { SendParams } from '../../worker/SendParams';
import type WorkerConst from '../../worker/WorkerConst';
import DeleteRestoreConst from './DeleteRestoreConst';
import type common from '@ohos.app.ability.common';
import type { DiskInfo } from '../../externel/DiskInfo';
import type { FavoriteModel } from '../../model/FavoriteModel';

/**
 * 文件删除、还原请求的消息体
 */
export class DeleteRestoreSendParam extends SendParams {
  /**
   * 要操作的文件 FileInfo 数组
   */
  public toOperateFiles: FileInfo[];

  /**
   * 消息指令
   */
  public msgCode: DeleteRestoreConst.SendMsgCode;

  /**
   * 任务类型：永久删除、从回收站删除、还原
   */
  public taskType: DeleteRestoreConst.TaskType;

  /**
   * 冲突处理结果
   */
  public conflictHandleResult?: DeleteRestoreConst.ChooseType;

  /**
   * 是否应用到全部
   */
  public isApplyToAll: boolean;

  /**
   * 挂载盘符信息
   */
  public diskInfoList: DiskInfo[] = [];

  /**
   * 收藏列表
   */
  public favoriteList: FavoriteModel[] = [];

  /**
   * 还原至指定文件夹，为空则原路返回
   */
  public specifiedDir: string = '';

  /**
   * 是否聚合视图下删除操作，
   */
  public mediaSearchType: number = -1;

  /**
   * 是否显示隐藏文件
   */
  public isShowHiddenItem: boolean = false;

  constructor(context: common.Context, operateType: WorkerConst.OperateType, workerName: string,
    toOperateFiles: FileInfo[], msgCode: DeleteRestoreConst.SendMsgCode,
    conflictHandleResult?: DeleteRestoreConst.ChooseType, isApplyToAll?: boolean, specifiedDir: string = '',
    taskType?: DeleteRestoreConst.TaskType, isShowHiddenItem: boolean = false) {
    super(context, operateType, workerName);
    this.toOperateFiles = toOperateFiles;
    this.msgCode = msgCode;
    this.taskType = taskType ?? DeleteRestoreConst.TaskType.SOFT_DELETE;
    this.conflictHandleResult = conflictHandleResult;
    this.isApplyToAll = isApplyToAll ?? false;
    this.specifiedDir = specifiedDir;
    this.isShowHiddenItem = isShowHiddenItem;
  }
}