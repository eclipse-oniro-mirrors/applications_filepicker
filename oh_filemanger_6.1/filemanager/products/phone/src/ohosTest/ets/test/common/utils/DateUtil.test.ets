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
import { describe, expect, it } from '@ohos/hypium';
import { DateUtil, Constant } from '@ohos/common';

// DT测试用日期数据
const testDateData = [
  1712883419000, // 2024/4/12 08:56:59
  1712899999000 // 2024/4/12 13:33:19
];

const systemLanguageList = [
  'zh-Hans', // 中文
  'en-Latn-US' // 英文
]

export default function DateUtilTest() {
  describe('DateUtilTest', () => {
    it('getPhoneDateTextWithUndefinedTimestamp', 0, () => {
      expect(DateUtil.getPhoneDateText(undefined)).assertEqual('');
    });

    it('getPhoneDateTextWithTodayDate', 0, () => {
      let timeStamp = Date.now();
      expect(DateUtil.getPhoneDateText(timeStamp))
        .assertEqual(DateUtil.formatDate(timeStamp, DateUtil.DATE_FORMAT.HH_MM));
    });

    it('getPhoneDateTextWithYesterdayDate', 0, () => {
      let timeStamp = Date.now() - Constant.TIME.ONE_DAY;
      expect(DateUtil.getPhoneDateText(timeStamp)).assertDeepEquals($r('app.string.yesterday'));
    });

    it('getPhoneDateTextWithDayBeforeYesterdayDate', 0, () => {
      let timeStamp = Date.now() - Constant.TIME.ONE_DAY * 2;
      expect(DateUtil.getPhoneDateText(timeStamp)).assertEqual(DateUtil.formatDate(timeStamp));
    });

    it('isDayTodayWhenCurrentTimeIsWithinToday', 0, () => {
      const todayNoon = new Date().setHours(12, 0, 0, 0);
      expect(DateUtil.isDayToday(Date.now(), todayNoon)).assertTrue();
    });

    it('isDayTodayWhenCurrentTimeIsYesterday', 0, () => {
      const yesterdayMidnight = Date.now() - Constant.TIME.ONE_DAY;
      expect(DateUtil.isDayToday(Date.now(), yesterdayMidnight)).assertFalse();
    });

    it('isDayTodayWhenCurrentTimeIsBeforeMidnight', 0, () => {
      const todayStart = new Date().setHours(0, 0, 0, 0);
      const beforeMidnight = todayStart - 1;
      expect(DateUtil.isDayToday(todayStart, beforeMidnight)).assertFalse();
    });

    it('isDayTodayWhenCurrentTimeIsAtMidnight', 0, () => {
      const todayStart = new Date().setHours(0, 0, 0, 0);
      const atMidnight = todayStart + 1;
      expect(DateUtil.isDayToday(todayStart, atMidnight)).assertTrue();
    });

    it('get24HourClickDateWithoutMillisecondsMorning', 0, () => {
      expect(DateUtil.get24HourClickDate(testDateData[0])).assertEqual('2024/04/12 08:56');
    })

    it('get24HourClickDateWithoutMillisecondsAfternoon', 0, () => {
      expect(DateUtil.get24HourClickDate(testDateData[1])).assertEqual('2024/04/12 13:33');
    })

    it('get24HourClickDateWithMillisecondsMorining', 0, () => {
      expect(DateUtil.get24HourClickDate(testDateData[0], true)).assertEqual('2024/04/12 08:56:59');
    })

    it('get24HourClickDateWithMillisecondsAfternoon', 0, () => {
      expect(DateUtil.get24HourClickDate(testDateData[1], true)).assertEqual('2024/04/12 13:33:19');
    })

    it('testGet24HourClickDateWithZeroTimestamp', 0, () => {
      expect(DateUtil.get24HourClickDate(0)).assertEqual('1970/01/01 08:00');
    });

    it('getDayBeginTimeStampWithCurrentTimestamp', 0, () => {
      let timestamp: number = new Date().getTime();
      let expected: number = new Date(new Date().setHours(0, 0, 0, 0)).getTime();
      expect(DateUtil.getDayBeginTimeStamp(timestamp)).assertEqual(expected);
    });

    it('getDayBeginTimeStampWithZeroTimestamp', 0, () => {
      let timestamp: number = 0;
      let expected: number = new Date('1970/01/01 00:00:00').getTime();
      expect(DateUtil.getDayBeginTimeStamp(timestamp)).assertEqual(expected);
    });

    it('formatDurationWithOneHour', 0, () => {
      expect(DateUtil.formatDuration(3600000)).assertEqual('01:00:00');
    });

    it('formatDurationWithHalfHour', 0, () => {
      expect(DateUtil.formatDuration(1800000)).assertEqual('30:00');
    });

    it('formatDurationWithOneHourAndOneMinute', 0, () => {
      expect(DateUtil.formatDuration(3660000)).assertEqual('01:01:00');
    });

    it('formatDurationWithTenHours', 0, () => {
      expect(DateUtil.formatDuration(36000000)).assertEqual('10:00:00');
    });

    it('formatDurationWithZero', 0, () => {
      expect(DateUtil.formatDuration(0)).assertEqual('00:00');
    });

    it('formatFullDurationWithNormalTime', 0, () => {
      expect(DateUtil.formatFullDuration(11730000)).assertEqual('03:15:30');
    });

    it('formatFullDurationWithMinutes', 0, () => {
      expect(DateUtil.formatFullDuration(45000)).assertEqual('00:00:45');
    });

    it('formatFullDurationWithOverflow', 0, () => {
      expect(DateUtil.formatFullDuration(93600000)).assertEqual('26:00:00');
    });

    it('changeSecondTimestampToMillisecond', 0, () => {
      const secondStamp = 1633021200;
      expect(DateUtil.changeTimeToMills(secondStamp)).assertEqual(secondStamp * 1000);
    });

    it('changeMillisecondTimestampToMillisecond', 0, () => {
      const milliStamp = 1633021200000;
      expect(DateUtil.changeTimeToMills(milliStamp)).assertEqual(milliStamp);
    });

    it('formatDateWithYYYY_MM_DDFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.YYYY_MM_DD)).assertEqual('2024/04/12');
    });

    it('formatDateWithMM_DDFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.MM_DD)).assertEqual('04/12');
    });

    it('formatDateWithDateTimeFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.DATE_TIME)).assertEqual('2024/04/12 08:56:59');
    });

    it('formatDateWithYYYY_MM_DD_ChineseFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.YYYY_MM_DD_CHINESE)).assertEqual('2024年04月12日');
    });

    it('formatDateWithMM_DD_ChineseFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.MM_DD_CHINESE)).assertEqual('04月12日');
    });

    it('formatDateWithDateTime_ChineseFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.DATE_TIME_CHINESE)).assertEqual('2024年04月12日 08:56');
    });

    it('formatDateWithHH_MMFormat', 0, () => {
      let timestamp = testDateData[0];
      expect(DateUtil.formatDate(timestamp, DateUtil.DATE_FORMAT.HH_MM)).assertEqual('08:56');
    });
  })
}
