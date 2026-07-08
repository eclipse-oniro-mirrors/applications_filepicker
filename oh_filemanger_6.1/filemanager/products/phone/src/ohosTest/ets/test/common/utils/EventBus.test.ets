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
import { EventBus, HiLog } from "@ohos/common";
import { afterEach, beforeEach, describe, expect, it } from "@ohos/hypium";
import { TestUtil } from "../../utils/TestUtil";

const TAG: string = 'EventBusTest';

class CallBackObj {
  fun: Function = () => {
  };
  isOnce: boolean = false;
}

class EventObj {
  funList: Array<CallBackObj> = [];
  isOnlyRunLastFun: boolean = false;

  constructor() {
    this.funList = [];
    this.isOnlyRunLastFun = false;
  }
}

export default function EventBusTest() {
  describe('EventBusTest', () => {

    beforeEach(() => {

    });
    afterEach(() => {

    });


    it('should_add_callback_to_event_when_event_does_not_exist', 0, () => {
      let event: string = "testEvent";
      let callback: Function = () => {
        HiLog.info(TAG, "callback called");
      };
      let isOnlyRunLastFun: boolean = false;

      EventBus.on(event, callback, isOnlyRunLastFun);

      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      let eventObj = eventMap.get(event);
      expect(eventObj).not().assertUndefined();
      expect(eventObj?.funList.length).assertEqual(1);
      expect(eventObj?.funList[0].fun).assertEqual(callback);
      expect(eventObj?.isOnlyRunLastFun).assertEqual(isOnlyRunLastFun);
      EventBus.off(event, callback);
    });

    it('should_add_callback_to_event_when_event_exists', 0, () => {
      let event: string = "testEvent";
      let callback1: Function = () => {
        HiLog.info(TAG, "callback1 called");
      };
      let callback2: Function = () => {
        HiLog.info(TAG, "callback2 called");
      };
      let isOnlyRunLastFun: boolean = false;

      EventBus.on(event, callback1, isOnlyRunLastFun);
      EventBus.on(event, callback2, isOnlyRunLastFun);

      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      let eventObj = eventMap.get(event);
      expect(eventObj).not().assertUndefined();
      expect(eventObj?.funList.length).assertEqual(2);
      expect(eventObj?.funList[0].fun).assertEqual(callback1);
      expect(eventObj?.funList[1].fun).assertEqual(callback2);
      expect(eventObj?.isOnlyRunLastFun).assertEqual(isOnlyRunLastFun);
      EventBus.off(event, callback1);
      EventBus.off(event, callback2);
    });

    it('should_return_immediately_when_eventObj_is_null_or_undefined', 0, () => {
      let event: string = "testEvent";
      let callback: Function | undefined = undefined;
      EventBus.off(event, callback);
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      let eventObj = eventMap.get(event);
      expect(eventObj).assertUndefined();
    });

    it('should_delete_event_from_eventMap_when_callback_is_null_or_undefined', 0, () => {
      let event: string = "testEvent";
      let callback: Function | undefined = undefined;
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      eventMap.set(event, {
        funList: [{
          fun: () => {
          },
          isOnce: false
        }], isOnlyRunLastFun: false
      });
      EventBus.off(event, callback);
      expect(eventMap.get(event)).assertUndefined();
    });

    it('should_remove_callback_from_funList_when_callback_is_specified', 0, () => {
      let event: string = "testEvent";
      let callback: Function = () => {
      };
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      eventMap.set(event, {
        funList: [{
          fun: callback, isOnce: false
        }, {
          fun: () => {
          }, isOnce: false
        }], isOnlyRunLastFun: false
      });
      EventBus.off(event, callback);
      expect(eventMap.get(event)?.funList.length).assertEqual(1);
    });

    it('should_not_remove_callback_from_funList_when_callback_is_specified_but_not_found', 0, () => {
      let event: string = "testEvent";
      let callback: Function = () => {
      };
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      eventMap.set(event, {
        funList: [{
          fun: () => {
          }, isOnce: false
        }], isOnlyRunLastFun: false
      });
      EventBus.off(event, callback);
      expect(eventMap.get(event)?.funList.length).assertEqual(1);
    });

    it('should_delete_event_from_eventMap_when_funList_length_reaches_1', 0, () => {
      let event: string = "testEvent";
      let callback: Function = () => {
      };
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      eventMap.clear();
      EventBus.off(event, callback);
      expect(eventMap.get(event)).assertUndefined();
    });

    it('should_not_delete_event_from_eventMap_when_funList_length_does_not_reach_1', 0, () => {
      let event: string = "testEvent";
      let callback: Function = () => {
      };
      let callback2: Function = () => {
      };
      const eventMap: Map<string, EventObj> =
        TestUtil.getPrivateAttribute(EventBus, 'eventMap') as Map<string, EventObj>;
      eventMap.set(event, {
        funList: [{
          fun: callback,
          isOnce: true
        }, {
          fun: () => {
          },
          isOnce: true
        }], isOnlyRunLastFun: true
      });
      EventBus.off(event, callback2);
      expect(eventMap.get(event)?.funList.length).assertEqual(2);
    });

    it('EventBusTest_should_register_event_and_callback_when_event_does_not_exist', 0, () => {
      TestUtil.setPrivateAttribute<Map<string, EventObj>>(EventBus, 'eventMap', new Map<string, EventObj>());
      let event: string = "testEvent";
      let callback: Function = (data: string) => {
        HiLog.info(TAG, "callback called with data: " + data);
      };
      EventBus.once(event, callback);
      const eventMap: Map<string, EventObj> = TestUtil.getPrivateAttribute<Map<string, EventObj>>(EventBus, 'eventMap');
      let eventObj: ESObject = eventMap.get(event);
      expect(eventObj).not().assertNull();
      expect(eventObj.funList.length).assertEqual(1);
      expect(eventObj.funList[0].fun).assertEqual(callback);
      expect(eventObj.funList[0].isOnce).assertTrue();
    });

    it('EventBusTest_should_register_event_and_callback_when_event_exists_and_callback_is_once', 0, () => {
      TestUtil.setPrivateAttribute<Map<string, EventObj>>(EventBus, 'eventMap', new Map<string, EventObj>());
      let event: string = "testEvent";
      let callback1: Function = (data: string) => {
        HiLog.info(TAG, "callback1 called with data: " + data);
      };
      let callback2: Function = (data: string) => {
        HiLog.info(TAG, "callback2 called with data: " + data);
      };
      EventBus.once(event, callback1);
      EventBus.once(event, callback2);
      const eventMap: Map<string, EventObj> = TestUtil.getPrivateAttribute<Map<string, EventObj>>(EventBus, 'eventMap');
      let eventObj: ESObject = eventMap.get(event);
      expect(eventObj).not().assertNull();
      expect(eventObj.funList.length).assertEqual(2);
      expect(eventObj.funList[0].fun).assertEqual(callback1);
      expect(eventObj.funList[0].isOnce).assertTrue();
      expect(eventObj.funList[1].fun).assertEqual(callback2);
      expect(eventObj.funList[1].isOnce).assertTrue();
    });

    it('EventBusTest_should_clear_timeout_when_timerId_is_not_null', 0, () => {
      TestUtil.setPrivateAttribute<Map<string, number>>(EventBus, 'emitDelayTimerMap', new Map<string, number>());
      let event: string = "testEvent";
      let timerId: number = 12345;
      const emitDelayTimerMap: Map<string, number> =
        TestUtil.getPrivateAttribute<Map<string, number>>(EventBus, 'emitDelayTimerMap');
      emitDelayTimerMap.set(event, timerId);
      EventBus.removeEmit(event);
      expect(emitDelayTimerMap.get(event)).assertUndefined();
    });

    it('EventBusTest_should_do_nothing_when_timerId_is_null', 0, () => {
      TestUtil.setPrivateAttribute<Map<string, number>>(EventBus, 'emitDelayTimerMap', new Map<string, number>());
      let event: string = "testEvent";
      const emitDelayTimerMap: Map<string, number> =
        TestUtil.getPrivateAttribute<Map<string, number>>(EventBus, 'emitDelayTimerMap');
      EventBus.removeEmit(event);
      expect(emitDelayTimerMap.get(event)).assertUndefined();
    });
  });
}