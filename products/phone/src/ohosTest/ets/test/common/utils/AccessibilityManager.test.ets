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
import { AccessibilityManager, DateUtil, DisplayTimeUtil, FileInfo,
  HiLog,
  MimeType, ResourceUtil } from "@ohos/common";
import { ArgumentMatchers, describe, expect, it, MockKit, when } from "@ohos/hypium";

export default function AccessibilityManagerTest() {
  describe('AccessibilityManagerTest', () => {
    it('AccessibilityModeWhenDisabled', 0, (done: Function) => {
      AccessibilityManager.getInstance().unregisterAccessibilityModeListener();
      AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility('AccessibilityModeOne');
      AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility('AccessibilityModeOne');
      AccessibilityManager.getInstance().announcedString('AccessibilityModeOne');
      expect(AccessibilityManager.getInstance().getIsAccessibilityMode()).assertFalse();
      done();
    })

    it('AccessibilityModeWhenEnabled', 0, async (done: Function) => {
      expect(AccessibilityManager.getInstance().getIsAccessibilityMode()).assertFalse();
      AccessibilityManager.getInstance().initAccessibilityModeListener();
      AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility('AccessibilityModeOne');
      AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility('AccessibilityModeOne');
      AccessibilityManager.getInstance().announcedString('AccessibilityModeOne');
      AccessibilityManager.getInstance().unregisterAccessibilityModeListener();
      expect(AccessibilityManager.getInstance().getIsAccessibilityMode()).assertFalse();
      done();
    })

    it("getMediaFileAccessibilityText_NULL", 0, () => {
      let param: FileInfo[] = [];
      const str1 = AccessibilityManager.getMediaFileAccessibilityText(param[2], 0, 'zh-cn');
      expect(str1).assertEqual('');
    })

    it("getMediaFileAccessibilityText_Video", 0, () => {
      const file1: FileInfo = new FileInfo();
      file1.mimeTypeObj = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      file1.mtime = 1111111;
      const dateStr: string = DisplayTimeUtil.get12HourDateStr('zh-cn', new Date(file1.mtime));
      const str2 = AccessibilityManager.getMediaFileAccessibilityText(file1, 0, 'zh-cn');
      expect(str2).assertEqual(ResourceUtil.getStringByResource($r('app.string.video_broadcast', `1 , ${dateStr}`,
        DateUtil.formatFullDuration(0))));
    })

    it("getMediaFileAccessibilityText_Image", 0, () => {
      const file1: FileInfo = new FileInfo();
      file1.mimeTypeObj = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      file1.mtime = 1111111;
      const dateStr: string = DisplayTimeUtil.get12HourDateStr('zh-cn', new Date(file1.mtime));
      const str2 = AccessibilityManager.getMediaFileAccessibilityText(file1, 0, 'zh-cn');
      expect(str2).assertEqual(ResourceUtil.getStringByResource($r('app.string.image')) + `1 , ${dateStr}`);
    })

    it("announceForAccessibilityNotInterrupt", 0, () => {
      let mocker = new MockKit();
      let mockFunc =
        mocker.mockFunc(AccessibilityManager.getInstance(), AccessibilityManager.getInstance().getIsAccessibilityMode);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      AccessibilityManager.getInstance().announceForAccessibilityNotInterrupt('', '');
      expect(AccessibilityManager.getInstance().getIsAccessibilityMode()).assertFalse();
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      AccessibilityManager.getInstance().announceForAccessibilityNotInterrupt('', '');
      expect(AccessibilityManager.getInstance().getIsAccessibilityMode()).assertTrue();
      mocker.ignoreMock(AccessibilityManager.getInstance(), AccessibilityManager.getInstance().getIsAccessibilityMode);
    })

    it("announcedStringAndFocusComponentNotAccessibilityMode", 0, () => {
      let mocker = new MockKit();
      let mockFunc =
        mocker.mockFunc(AccessibilityManager.getInstance(),
          AccessibilityManager.getInstance().getIsAccessibilityMode);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      mocker.mockFunc(HiLog, HiLog.warn);
      AccessibilityManager.getInstance().announcedStringAndFocusComponent('', '');
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['AccessibilityManager', 'announcedStringAndFocusComponent: customId is empty.'])
        .never();
      mocker.ignoreMock(AccessibilityManager.getInstance(),
        AccessibilityManager.getInstance().getIsAccessibilityMode);
    })

    it("announcedStringAndFocusComponentEmptyCustomId", 0, () => {
      let mocker = new MockKit();
      let mockFunc =
        mocker.mockFunc(AccessibilityManager.getInstance(),
          AccessibilityManager.getInstance().getIsAccessibilityMode);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(HiLog, HiLog.warn);
      AccessibilityManager.getInstance().announcedStringAndFocusComponent('', '');
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['AccessibilityManager', 'announcedStringAndFocusComponent: customId is empty.'])
        .once();
      mocker.ignoreMock(AccessibilityManager.getInstance(),
        AccessibilityManager.getInstance().getIsAccessibilityMode);
    })

    it("announcedStringAndFocusComponentValidCustomId", 0, () => {
      let mocker = new MockKit();
      let mockFunc =
        mocker.mockFunc(AccessibilityManager.getInstance(),
          AccessibilityManager.getInstance().getIsAccessibilityMode);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(HiLog, HiLog.warn);
      AccessibilityManager.getInstance().announcedStringAndFocusComponent('', 'test');
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['AccessibilityManager', 'announcedStringAndFocusComponent: customId is empty.'])
        .never();
      mocker.ignoreMock(AccessibilityManager.getInstance(),
        AccessibilityManager.getInstance().getIsAccessibilityMode);
    })
  })
}