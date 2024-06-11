/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2022. All rights reserved.
 */

/**
 * [日志工具类]<BR>
 *
 * @author
 * @version [V1.0.0.0, 2021/12/28]
 * @since V1.0.0.0
 */
// app tag
import hilog from '@ohos.hilog'

// import { LOG, HiLogNode, Logger as Hlogger } from '@hw-hmf/logger'

const APP_TAG = "HwMsc_"
const DOMAIN = 0x0001

// Hlogger.config(new HiLogNode(DOMAIN))
export class Logger {
  static domain: number = DOMAIN
  prefix: string;


  constructor(module: string | number) {
    this.prefix = APP_TAG + module;
  }

  debug(message: string, ...args: any[]): void {
    hilog.debug(Logger.domain, this.prefix, message, args)
  }

  log(message: string, ...args: any[]): void {
    hilog.debug(Logger.domain, this.prefix, message, args)
  }

  info(message: string, ...args: any[]): void {
    hilog.info(Logger.domain, this.prefix, message, args)
  }

  warn(message: string, ...args: any[]): void {
    hilog.warn(Logger.domain, this.prefix, message, args)
  }

  error(message: string, ...args: any[]): void {
    hilog.error(Logger.domain, this.prefix, message, args)
  }
}

