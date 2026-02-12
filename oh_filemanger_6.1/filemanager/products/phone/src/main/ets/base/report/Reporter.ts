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

import { ReportConst } from '../const/ReportCont';

const TAG = 'Reporter';

export class Reporter {
  /**
   * 打点Id,默认使用"HMFILEMANAGER",该ID需要在管控平台录入，如果业务需要使用其他，请确保已在平台录入
   */
  private _eventId: string = ReportConst.EVENT_ID;

  /**
   *  包名+模块名（使用\001分隔）
   */
  private _packageName: string;


  /**
   * 请求操作类型（详见数据打点字典）
   */
  private _operation: string;

  /**
   * 事务ID
   */
  private _transID: string;

  /**
   * 客户端或服务器接口名称
   */
  private _cmd: string;

  /**
   * 返回码
   */
  private _code: string;

  /**
   * 返回描述
   */
  private _msg: string;

  /**
   * 任务类型
   */
  private _taskType: string;

  public constructor(packageName: string, operation: string, transID: string, cmd: string) {
    this._packageName = packageName;
    this._operation = operation;
    this._transID = transID;
    this._cmd = cmd;
  }

  public get eventId(): string {
    return this._eventId;
  }

  public get packageName(): string {
    return this._packageName;
  }

  public get operation(): string {
    return this._operation;
  }


  public get transID(): string {
    return this._transID;
  }

  public get cmd(): string {
    return this._cmd;
  }


  public get code(): string {
    return this._code;
  }


  public get msg(): string {
    return this._msg;
  }

  public get taskType(): string {
    return this._taskType;
  }

  /**
   *
   * @param code 返回码
   * @returns
   */
  public setCode(code: string): Reporter {
    this._code = code;
    return this;
  }

  /**
   * 设置打点Id,默认使用"HMFILEMANAGER",该ID需要在管控平台录入，如果业务需要使用其他，请确保已在平台录入
   */
  public setEventId(eventId: string): Reporter {
    this._eventId = eventId;
    return this;
  }

  /**
   *
   * @param msg 返回描述
   * @returns
   */
  public setMsg(msg: string): Reporter {
    this._msg = msg;
    return this;
  }

  /**
   * 设置任务类型
   * @param msg 任务类型
   * @returns
   */
  public setTaskType(taskType: string): Reporter {
    this._taskType = taskType;
    return this;
  }
}