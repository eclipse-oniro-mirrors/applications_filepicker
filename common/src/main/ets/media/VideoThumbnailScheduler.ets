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

import type { FileInfo } from '../fileoperate/FileInfo';
import { MediaThumbnailConst } from './MediaThumbnailConst';
import { HiLog } from '../dfx/HiLog';
import { VideoThumbnailSupportUtil } from './VideoThumbnailSupportUtil';
import { StringUtil } from '../utils/StringUtil';

const TAG = 'VideoThumbnailScheduler';

/** 缩略图加载优先级：数值越小越优先 */
export enum VideoThumbnailPriority {
  /** 列表项进入可见区域 */
  HIGH = 0,
  /** 默认入队优先级 */
  LOW = 1,
}

/** 等待队列中的缩略图任务 */
interface ThumbnailQueueItem {
  uri: string;
  fileInfo: FileInfo;
  priority: VideoThumbnailPriority;
  resolve: (uri: string) => void;
  reject: (error: Error) => void;
  /** 列表项滑出可见区或复用时标记为已取消 */
  cancelled: boolean;
}

/** 实际执行缩略图加载的回调，由 ThumbnailUtil 注入以避免循环依赖 */
type ThumbnailLoadExecutor = (fileInfo: FileInfo) => Promise<string>;

/**
 * 本地视频缩略图全局调度器。
 * - 限制 AV 抽帧并发（与 MediaThumbnailConst.MAX_CONCURRENT_TASK_NUM 一致）
 * - 可见区 HIGH 优先于 LOW
 * - 滚动中暂停 LOW，停止滚动后继续 pump
 * - 同 URI 去重、等待队列可取消
 */
export class VideoThumbnailScheduler {
  private static instance: VideoThumbnailScheduler;
  /** 当前正在执行的任务数 */
  private runningCount: number = 0;
  private waitQueue: ThumbnailQueueItem[] = [];
  /** 同一文件只保留一个进行中的 Promise，后续请求可升级优先级 */
  private inflightByUri: Map<string, Promise<string>> = new Map();
  /** 列表滚动中为 true，仅调度 HIGH 任务 */
  private scrollPaused: boolean = false;
  private loadExecutor: ThumbnailLoadExecutor | undefined;

  static getInstance(): VideoThumbnailScheduler {
    if (!VideoThumbnailScheduler.instance) {
      VideoThumbnailScheduler.instance = new VideoThumbnailScheduler();
    }
    return VideoThumbnailScheduler.instance;
  }

  setLoadExecutor(executor: ThumbnailLoadExecutor): void {
    this.loadExecutor = executor;
  }

  onScrollStart(): void {
    this.scrollPaused = true;
    HiLog.debug(TAG, 'onScrollStart, pause low priority thumbnail');
  }

  /** 滚动结束，恢复低优先级任务调度 */
  onScrollStop(): void {
    this.scrollPaused = false;
    HiLog.debug(TAG, 'onScrollStop, resume thumbnail queue');
    this.pump();
  }

  /**
   * 列表项滑出可见区或复用时，从等待队列移除对应任务。
   */
  cancelPending(fileUri: string): void {
    if (!fileUri) {
      return;
    }
    const remainItems: ThumbnailQueueItem[] = [];
    let removedCount = 0;
    for (const item of this.waitQueue) {
      if (item.uri === fileUri) {
        item.cancelled = true;
        item.resolve('');
        removedCount++;
      } else {
        remainItems.push(item);
      }
    }
    this.waitQueue = remainItems;
    if (removedCount > 0) {
      HiLog.debug(TAG, `cancelPending uri removed count = ${removedCount}`);
    }
  }

  /**
   * 请求加载视频缩略图；不支持格式在入队前直接返回空串。
   */
  requestThumbnail(fileInfo: FileInfo, priority: VideoThumbnailPriority): Promise<string> {
    const uri = fileInfo?.uri ?? '';
    if (!uri) {
      return Promise.resolve('');
    }
    // 扩展名黑名单：不入队，UI 保持默认视频图标
    if (VideoThumbnailSupportUtil.shouldSkipByExtension(fileInfo)) {
      fileInfo.isLoadThumbnailError = true;
      return Promise.resolve('');
    }
    if (!this.loadExecutor) {
      HiLog.error(TAG, 'requestThumbnail loadExecutor is not set');
      return Promise.resolve('');
    }
    const existing = this.inflightByUri.get(uri);
    if (existing) {
      this.upgradePriority(uri, priority);
      return existing;
    }
    const taskPromise = new Promise<string>((resolve, reject) => {
      const queueItem: ThumbnailQueueItem = {
        uri,
        fileInfo,
        priority,
        resolve,
        reject,
        cancelled: false
      };
      this.enqueue(queueItem);
      this.pump();
    });
    this.inflightByUri.set(uri, taskPromise);
    taskPromise.finally(() => {
      if (this.inflightByUri.get(uri) === taskPromise) {
        this.inflightByUri.delete(uri);
      }
    });
    return taskPromise;
  }

  /** 同一 URI 已在队列等待时，将优先级提升为更高（数值更小） */
  private upgradePriority(uri: string, priority: VideoThumbnailPriority): void {
    const item = this.waitQueue.find(queueItem => queueItem.uri === uri);
    if (!item || item.priority <= priority) {
      return;
    }
    item.priority = priority;
    this.sortQueue();
  }

  /** 按优先级插入等待队列（HIGH 靠前） */
  private enqueue(item: ThumbnailQueueItem): void {
    const insertIndex = this.waitQueue.findIndex(queueItem => queueItem.priority > item.priority);
    if (insertIndex === -1) {
      this.waitQueue.push(item);
    } else {
      this.waitQueue.splice(insertIndex, 0, item);
    }
  }

  private sortQueue(): void {
    this.waitQueue.sort((left, right) => left.priority - right.priority);
  }

  /**
   * 在并发上限内从队列取出任务并执行；
   * 滚动暂停时仅消费 HIGH 优先级项。
   */
  private pump(): void {
    while (this.runningCount < MediaThumbnailConst.MAX_CONCURRENT_TASK_NUM && this.waitQueue.length > 0) {
      const nextIndex = this.waitQueue.findIndex(queueItem => {
        return !this.scrollPaused || queueItem.priority === VideoThumbnailPriority.HIGH;
      });
      if (nextIndex === -1) {
        break;
      }
      const queueItem = this.waitQueue.splice(nextIndex, 1)[0];
      if (queueItem.cancelled) {
        continue;
      }
      this.runningCount++;
      HiLog.info(TAG,
        `start thumbnail uri=${queueItem.uri}, running=${this.runningCount}, queue=${this.waitQueue.length}`);
      this.executeItem(queueItem);
    }
  }

  private executeItem(queueItem: ThumbnailQueueItem): void {
    const executor = this.loadExecutor;
    if (!executor) {
      queueItem.resolve('');
      this.runningCount--;
      this.pump();
      return;
    }
    executor(queueItem.fileInfo).then((uri: string) => {
      HiLog.info(TAG,
        `finish thumbnail uri=${queueItem.uri}, empty=${StringUtil.isEmpty(uri)}, running=${this.runningCount - 1}`);
      queueItem.resolve(queueItem.cancelled ? '' : uri);
    }).catch((error: Error) => {
      if (queueItem.cancelled) {
        queueItem.resolve('');
        return;
      }
      queueItem.reject(error);
    }).finally(() => {
      this.runningCount--;
      this.pump();
    });
  }
}
