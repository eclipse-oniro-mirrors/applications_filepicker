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

#ifndef FILEPRODUCER_H
#define FILEPRODUCER_H

#include <atomic>
#include <set>
#include <thread>
#include <sys/stat.h>

#include "common/common.h"
#include "napi/native_api.h"

namespace producer {
struct FileStat {
    std::string fileName;
    std::string filePath;
    struct stat statInfo;
};
template <typename T, size_t Capacity>
class LockFreeQueue {
    alignas(BUFFER_64) std::atomic<size_t> head_{0};  // 消费者索引
    alignas(BUFFER_64) std::atomic<size_t> tail_{0};  // 生产者索引
    T buffer_[Capacity];
    size_t next(size_t idx) const
    {
        return (idx + 1) % Capacity;
    }

public:
    bool isFinish()
    {
        size_t current_head = head_.load(std::memory_order_relaxed);
        size_t current_tail = tail_.load(std::memory_order_relaxed);
        return current_head == current_tail;
    }
    bool push(const T &item)
    {
        size_t current_tail = tail_.load(std::memory_order_relaxed);
        size_t next_tail = next(current_tail);
        if (next_tail == head_.load(std::memory_order_acquire)) {
            return false;
        }
        buffer_[current_tail] = item;
        tail_.store(next_tail, std::memory_order_release);
        return true;
    }
    bool pop(T &item)
    {
        size_t current_head = head_.load(std::memory_order_relaxed);
        if (current_head == tail_.load(std::memory_order_acquire)) {
            return false;
        }
        item = buffer_[current_head];
        head_.store(next(current_head), std::memory_order_release);
        return true;
    }
};

// FileInfo信息生产者
class FileProducer {
    LockFreeQueue<FileStat, BUFFER_256KB> fileQueue;
    std::atomic<bool> isProducerDone{false};
    napi_env env;
    napi_value callbackFunc;

    std::string folderUri;
    std::string folderPath;
    size_t batchCount;

public:
    void setParam(napi_env envIn, napi_value &callbackFuncIn, const std::string &folderPathIn,
        const size_t batchCountIn);  // 设置参数
    static void *producer(void *arg);
    void consumer();
    void start();
    napi_value getFileInfoNapi(FileStat &fileStat);
    bool returnResult(napi_value fileInfoList, bool isFinish);
    static bool getFileInfoListHandle(
        napi_env envIn, std::string &folderPathIn, size_t batchCountIn, napi_value &callbackFuncIn);
};
}  // namespace producer
napi_value NAPI_queryFiles(napi_env env, napi_callback_info info);
#endif  // FILEPRODUCER_H