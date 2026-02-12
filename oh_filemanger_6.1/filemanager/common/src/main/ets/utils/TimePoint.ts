/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

export enum TimeConst {
  HOUR_PER_DAY = 24,
  SECOND_PER_MINUTE = 60,
  MINUTE_PER_HOUR = 60,
  MILLISECOND_PER_SECOND = 1000,
  DAY_PER_WEEK = 7,
  SIX_DAYS = 6,
  ELEVEN_MONTHS = 11,
  ONE_DAY_TIMESTAMP = 86400000 // 每天的毫秒数 24 * 60 * 60 * 1000
}

export class TimePoint {
  todayStartSeconds: number;
  yesterdayStartSeconds: number;
  thisWeekStartSeconds: number;
  lastWeekStartSeconds: number;
  thisMonthStartSeconds: number;
  lastMonthStartSeconds: number;
  thisYearStartSeconds: number;

  constructor() {
    let nowTime = new Date();
    let nowYear = nowTime.getFullYear();
    let nowMonth = nowTime.getMonth();
    let nowDay = nowTime.getDate();

    let todayStart = new Date(nowYear, nowMonth, nowDay);
    let yesterdayStart = new Date(Date.parse(todayStart.toString()) - TimeConst.ONE_DAY_TIMESTAMP);
    let thisWeekTime = ((nowTime.getDay() + TimeConst.SIX_DAYS) % TimeConst.DAY_PER_WEEK) * TimeConst.ONE_DAY_TIMESTAMP;
    let thisWeekStart = new Date(Date.parse(todayStart.toString()) - thisWeekTime);
    let lastWeekStart = new Date(Date.parse(thisWeekStart.toString()) - TimeConst.DAY_PER_WEEK * TimeConst.ONE_DAY_TIMESTAMP);
    let thisMonthStart = new Date(nowYear, nowMonth);
    let yearOfLastMonthStart = (nowMonth === 0) ? nowYear - 1 : nowYear;
    let monthOfLastMonthStart = (nowMonth === 0) ? TimeConst.ELEVEN_MONTHS : nowMonth - 1;
    let lastMonthStart = new Date(yearOfLastMonthStart, monthOfLastMonthStart);
    let thisYearStart = new Date(nowYear, 0);

    this.todayStartSeconds = Date.parse(todayStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.yesterdayStartSeconds = Date.parse(yesterdayStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.thisWeekStartSeconds = Date.parse(thisWeekStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.lastWeekStartSeconds = Date.parse(lastWeekStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.thisMonthStartSeconds = Date.parse(thisMonthStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.lastMonthStartSeconds = Date.parse(lastMonthStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
    this.thisYearStartSeconds = Date.parse(thisYearStart.toString()) / TimeConst.MILLISECOND_PER_SECOND;
  }
}