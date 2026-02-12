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
import { beforeEach, describe, expect, it} from '@ohos/hypium';
import {
  DragManager,
  FileInfo,
  GlobalHolder,
  GlobalKey,
  PAGE_ROUTE_CONST,
  StartModeOptions
} from '@ohos/common';
import unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import UDC from '@ohos.data.unifiedDataChannel';
import { TestUtil } from '../../../test/utils/TestUtil';

let unifiedDataTemp: unifiedDataChannel.UnifiedData = new unifiedDataChannel.UnifiedData();
const event: DragEvent = {
  getGlobalDisplayX: (): number => {
    return 0;
  },
  getGlobalDisplayY: (): number => {
    return 0;
  },
  getDisplayX: (): number => {
    return 0;
  },
  getDisplayY: (): number => {
    return 0;
  },
  getWindowX: (): number => {
    return 0;
  },
  getWindowY: (): number => {
    return 0;
  },
  getX: (): number => {
    return 0;
  },
  getY: (): number => {
    return 0;
  },
  dragBehavior: DragBehavior.COPY,
  useCustomDropAnimation: false,
  setData: (unifiedData: unifiedDataChannel.UnifiedData): void => {
    unifiedDataTemp = unifiedData;
  },
  getData: (): unifiedDataChannel.UnifiedData => {
    return unifiedDataTemp;
  },
  getSummary: (): unifiedDataChannel.Summary => {
    return new unifiedDataChannel.Summary();
  },
  setResult: (dragResult: DragResult): void => {
    return;
  },
  getResult: (): DragResult => {
    return DragResult.DRAG_SUCCESSFUL;
  },
  getPreviewRect: (): Rectangle => {
    return {};
  },
  getVelocityX: (): number => {
    return 0;
  },
  getVelocityY: (): number => {
    return 0;
  },
  getVelocity: (): number => {
    return 0;
  },
  executeDropAnimation: (customDropAnimation: Callback<void, void>): void => {
    return;
  },
  startDataLoading: (options: DataSyncOptions): string => {
    return '';
  },
  getDisplayId: (): number => {
    return 0;
  },
  getDragSource: (): string => {
    return '';
  },
  isRemote: (): boolean => {
    return false;
  },
  setDataLoadParams: (dataLoadParams: DataLoadParams): void => {
    return;
  },
  enableInternalDropAnimation: (configuration: string): void => {
    return;
  }
}

interface DragClass {
  extraInfo: string;
}

export default function DragManagerTest() {
  describe('DragManagerTest', () => {
    beforeEach(() => {
      TestUtil.setPrivateAttribute(DragManager, 'instance', undefined);
    })

    it('getInstanceTest', 0, async (done: Function) => {
      expect(DragManager.getInstance()).not().assertEqual(undefined);
      done();
    })

    it('enterSelectItem_Tag_Empty_Test', 0, async (done: Function) => {
      DragManager.getInstance().selectItemTimeId = setTimeout(() => {}, 10000);
      DragManager.getInstance().selectItemTag = 'tag';
      DragManager.getInstance().enterSelectItem('');
      expect(DragManager.getInstance().selectItemTag).assertEqual('tag');
      done();
    })

    it('enterSelectItem_Tag_Test', 0, async (done: Function) => {
      DragManager.getInstance().selectItemTimeId = setTimeout(() => {}, 10000);
      DragManager.getInstance().selectItemTag = 'tag';
      DragManager.getInstance().enterSelectItem('test');
      expect(DragManager.getInstance().selectItemTag).assertEqual('test');
      done();
    })

    it('onDrop', 0, async (done: Function) => {
      DragManager.getInstance().dragTimeoutId = setTimeout(() => {}, 10000);
      DragManager.getInstance().onDrop();
      expect(DragManager.getInstance().dragTimeoutId).assertEqual(undefined);
      done();
    })

    it('storageItemCanDrop_Return_False_Test', 0, async (done: Function) => {
      let result: boolean = DragManager.getInstance().storageItemCanDrop(PAGE_ROUTE_CONST.RECENT_DELETE);
      expect(result).assertEqual(false);
      done();
    })

    it('storageItemCanDrop_Return_True_Test', 0, async (done: Function) => {
      let result: boolean = DragManager.getInstance().storageItemCanDrop('test');
      expect(result).assertEqual(true);
      done();
    })

    it('onDragStart_Empty_Test', 0, async (done: Function) => {
      let result: number = DragManager.getInstance().onDragStart(event, [], '/foldUri');
      expect(result).assertEqual(0);
      done();
    })

    it('onDragStart_Max_Num_Test', 0, async (done: Function) => {
      let list: FileInfo[] = [];
      for (let i = 0; i < 2001; i++) {
        list.push(new FileInfo());
      }
      let result: number = DragManager.getInstance().onDragStart(event, list, '/foldUri');
      expect(result).assertEqual(2001);
      done();
    })

    it('onDragStart_Empty_FileInfo_Test', 0, async (done: Function) => {
      let list: FileInfo[] = [new FileInfo(), new FileInfo()];
      let result: number = DragManager.getInstance().onDragStart(event, list, '/foldUri');
      expect(result).assertEqual(2);
      done();
    })

    it('getFileInfoListFromUDMF_Event_Null_Test', 0, async (done: Function) => {
      event.setData(undefined);
      let result: FileInfo[] = await DragManager.getInstance().getFileInfoListFromUDMF(event);
      expect(result.length).assertEqual(0);
      done();
    })

    it('getFileInfoListFromUDMF_Record_Empty_Test', 0, async (done: Function) => {
      event.setData(new unifiedDataChannel.UnifiedData());
      let result: FileInfo[] = await DragManager.getInstance().getFileInfoListFromUDMF(event);
      expect(result.length).assertEqual(0);
      done();
    })

    it('getFileInfoListFromUDMF_Uri_Empty_Test', 0, async (done: Function) => {
      let file1 = new UDC.File();
      let unfiedData = new unifiedDataChannel.UnifiedData();
      unfiedData.addRecord(file1);
      event.setData(unfiedData);
      let result: FileInfo[] = await DragManager.getInstance().getFileInfoListFromUDMF(event);
      expect(result.length).assertEqual(0);
      done();
    })

    it('getFileInfoListFromUDMF_Success_Test', 0, async (done: Function) => {
      GlobalHolder.getInstance().setObject<string>(GlobalKey.LOCAL_ROOT_URI, 'lyTest');
      DragManager.getInstance().isInternalDrag = true;
      let file2 = new UDC.File();
      file2.uri = 'file://docs/storage/Users/currentUser/Documents';
      let unfiedData = new unifiedDataChannel.UnifiedData();
      unfiedData.addRecord(file2);
      event.setData(unfiedData);
      let result: FileInfo[] = await DragManager.getInstance().getFileInfoListFromUDMF(event);
      expect(result.length).assertEqual(1);
      expect(result[0].isExternalStorageDeviceFile).assertTrue();
      done();
    })

    it('getFileInfoListFromUDMF_Illegal_FileUri', 0, async (done: Function) => {
      GlobalHolder.getInstance().setObject<string>(GlobalKey.LOCAL_ROOT_URI, 'Test');
      DragManager.getInstance().isInternalDrag = true;
      let file2 = new UDC.File();
      file2.uri = 'file:///docs/storage/Users/currentUser/Documents';
      let unfiedData = new unifiedDataChannel.UnifiedData();
      unfiedData.addRecord(file2);
      event.setData(unfiedData);
      let result: FileInfo[] = await DragManager.getInstance().getFileInfoListFromUDMF(event);
      expect(result.length).assertEqual(0);
      done();
    })

    it('leaveSelectItem', 0, async (done: Function) => {
      DragManager.getInstance().leaveSelectItem(() => {});
      expect(DragManager.getInstance().selectItemTimeId).not().assertEqual(undefined);
      done();
    })

    it('supportDrag', 0, async (done: Function) => {
      let options = new StartModeOptions();
      options.pickerFlag = false;
      let result = DragManager.getInstance().supportDrag(options);
      expect(result).assertTrue();
      done();
    })

    it('onDropEnterAnimation', 0, async (done: Function) => {
      DragManager.getInstance().onDropEnterAnimation(() => {}, () => {}, false);
      expect(DragManager.getInstance().dragTimeoutId).not().assertEqual(undefined);
      done();
    })

    it('onDropLeaveAnimation', 0, async (done: Function) => {
      DragManager.getInstance().dragTimeoutId = setTimeout(() => {}, 100);
      DragManager.getInstance().onDropLeaveAnimation(() => {});
      expect(DragManager.getInstance().dragTimeoutId).assertEqual(undefined);
      done();
    })

    it('getDragFlag', 0, async (done: Function) => {
      const dragInfo = GlobalHolder.getInstance().getObject<string>(GlobalKey.DRAG_INFO_TIME) ?? '';
      const dragParams: DragClass = { extraInfo: 'fhy Test' };
      DragManager.getInstance().getDragFlag(event, JSON.stringify(dragParams), dragInfo);
      expect(event.dragBehavior).assertEqual(DragBehavior.MOVE);
      done();
    })
  })
}