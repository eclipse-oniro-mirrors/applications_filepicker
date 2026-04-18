/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import intl from '@ohos.intl';
import { HiLog } from '../dfx/HiLog';
import { DateFormat } from '../model/Common';
import { StringUtil } from '../utils/StringUtil';
import { Constant } from '../const/Constant';

const TAG = 'DateUtil';

export class DateUtil {
  private static readonly TIME_ZERO: string = '00';
  private static readonly NUMBER_ZERO: number = 0;
  private static readonly NUMBER_NINE: number = 9;
  // 毫秒时间戳长度
  private static MILLI_SECOND_NUMBER_LENGTH: number = new Date().getTime().toString().length;
  // 日期格式缓存
  private static formatCache: Map<string, intl.DateTimeFormat> = new Map();
  // 正则表达式：匹配中文下的时间
  // eg：“上午8:00”
  private static regularExpr: RegExp = new RegExp('([\u4e00-\u9fa5][\u4e00-\u9fa5])(1?[0-2]|[1-9]):([0-5][0-9])');
  /**
   * 时间格式
   */
  public static readonly DATE_FORMAT: DateFormat = {
    YYYY_MM_DD: 'yyyy/mm/dd',
    MM_DD: 'mm/dd',
    DATE_TIME: 'yyyy/mm/dd HH:MM:SS',
    YYYY_MM_DD_CHINESE: 'yyyy年mm月dd日',
    MM_DD_CHINESE: 'm月d日',
    DATE_TIME_CHINESE: 'yyyy年mm月dd日 HH:MM',
    HH_MM: 'HH:MM'
  }

  /**
   * @description 手机格式化时间
   * @param timeStamp 时间戳,单位毫秒
   * @return 格式化时间，规则如下：
   *  当前日期同一天：MM:HH
   *  非当前日期：YYYY/MM/DD
   */
  public static getPhoneDateText(timeStamp: number | undefined): string | Resource {
    if (!timeStamp) {
      HiLog.info(TAG, `getPhoneDateText: date is undefined`);
      return '';
    }
    const targetDate: number = DateUtil.getDayBeginTimeStamp(timeStamp);
    const today: number = DateUtil.getDayBeginTimeStamp(Date.now());
    // 判断目标日期是否今天昨天，展示不同格式
    if (targetDate === today) {
      return DateUtil.formatDate(timeStamp, DateUtil.DATE_FORMAT.HH_MM);
    } else if (targetDate === (today - Constant.TIME.ONE_DAY)) {
      return $r('app.string.yesterday');
    } else {
      return DateUtil.formatDate(timeStamp);
    }
  }

  /**
   * 是否当天自然日，即当天0点开始
   * @param timestamp 日期时间戳，单位是ms
   * @return 是否当天
   */
  public static isDayToday(firstTime: number, recentTime: number): boolean {
    let isDayToday: boolean = false;
    const nowTime = new Date(firstTime);
    const nowYear = nowTime.getFullYear();
    const nowMonth = nowTime.getMonth();
    const nowDay = nowTime.getDate();
    const todayStart = new Date(nowYear, nowMonth, nowDay);
    const todayStartMs = todayStart.getTime();
    if (todayStartMs < recentTime) {
      isDayToday = recentTime - todayStartMs < Constant.TIME.ONE_DAY;
    }
    return isDayToday;
  }

  /*
   * 24小时制显示时间 例:2021/10/1 10:10
   * @param dateTime 日期时间戳
   * @return 格式化后的字符串
   */
  public static get24HourClickDate(dateTime: number, showSecond: boolean = false): string {
    const date: Date = new Date(dateTime);
    const year: number = date.getFullYear();
    const month: string = StringUtil.padStart(date.getMonth() + 1);
    const day: string = StringUtil.padStart(date.getDate());
    const hour: string = StringUtil.padStart(date.getHours());
    const minute: string = StringUtil.padStart(date.getMinutes());
    const second: string = StringUtil.padStart(date.getSeconds());
    return `${year}/${month}/${day} ${hour}:${minute}${showSecond ? ':' + second : ''}`;
  }

  /**
   * @description 获取指定时间戳当天0点的时间戳
   * @param timeStamp 指定时间戳
   * @return 当天0点的时间戳
   */
  public static getDayBeginTimeStamp(timeStamp: number): number {
    return new Date(timeStamp).setHours(0, 0, 0, 0);
  }

  /**
   * @description 将时长转化成时分秒
   * @param duration 时长
   * @return 格式化时长，如：08:20
   */
  public static formatDuration(duration: number): string {
    let remainTime: number = duration;
    const hours: number = Math.floor(remainTime / Constant.TIME.ONE_HOUR);
    remainTime -= hours * Constant.TIME.ONE_HOUR;
    const minutes: number = Math.floor(remainTime / Constant.TIME.ONE_MINUTE);
    remainTime -= minutes * Constant.TIME.ONE_MINUTE;
    const seconds: number = Math.floor(remainTime / Constant.TIME.ONE_SECOND);

    const minutesStr: string = StringUtil.padStart(minutes);
    const secondsStr: string = StringUtil.padStart(seconds);
    if (hours) {
      const hoursStr: string = StringUtil.padStart(hours);
      return `${hoursStr}:${minutesStr}:${secondsStr}`;
    } else {
      return `${minutesStr}:${secondsStr}`;
    }
  }

  /**
   * @description 将时长转化成时分秒
   * @param duration 时长
   * @return 格式化时长，如：00:08:20
   */
  public static formatFullDuration(duration: number): string {
    let remainTime: number = duration;
    const hours: number = Math.floor(remainTime / Constant.TIME.ONE_HOUR);
    remainTime -= hours * Constant.TIME.ONE_HOUR;
    const minutes: number = Math.floor(remainTime / Constant.TIME.ONE_MINUTE);
    remainTime -= minutes * Constant.TIME.ONE_MINUTE;
    const seconds: number = Math.floor(remainTime / Constant.TIME.ONE_SECOND);

    const minutesStr: string = StringUtil.padStart(minutes);
    const secondsStr: string = StringUtil.padStart(seconds);
    if (hours) {
      const hoursStr: string = StringUtil.padStart(hours);
      return `${hoursStr}:${minutesStr}:${secondsStr}`;
    } else {
      return `00:${minutesStr}:${secondsStr}`;
    }
  }

  /**
   * 日期格式转换
   * @param timestamp 时间戳
   * @param format 格式(可选)
   * @example formatDate(new Date(), "YYYY-mm-dd HH:MM:SS") => 2021-11-02 09:39:59
   */
  public static formatDate(timestamp: number, format: string = DateUtil.DATE_FORMAT.YYYY_MM_DD): string {
    let res: string = '';
    try {
      const date: Date = new Date(timestamp);
      let map: Map<string, string> = new Map();
      map.set('y+', date.getFullYear().toString());
      map.set('m+', (date.getMonth() + 1).toString());
      map.set('d+', date.getDate().toString());
      map.set('H+', date.getHours().toString());
      map.set('M+', date.getMinutes().toString());
      map.set('S+', date.getSeconds().toString());
      const iterator: IterableIterator<[string, string]> = map.entries();
      let item: IteratorResult<[string, string]> = iterator.next();
      while (!item.done) {
        let key: string = item.value[0];
        const reg: RegExp = new RegExp(key);
        let ret: RegExpExecArray | null = reg.exec(format);
        if (ret) {
          let value: string = item.value[1];
          format = format.replace(
            reg, value.length === 1 ? StringUtil.padStart(value) : value
          );
        }
        item = iterator.next();
      }
      res = format;
    } catch (error) {
      HiLog.error(TAG, 'formatDate error: ' + (error as Error).message);
    }
    return res;
  }

  public static changeTimeToMills(time: number) {
    return time?.toString().length < DateUtil.MILLI_SECOND_NUMBER_LENGTH ? time * Constant.TIME.ONE_SECOND : time;
  }

}