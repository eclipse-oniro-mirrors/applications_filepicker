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

#include "file_producer.h"
#include "common/common.h"
#include "fileoperation/file_util.h"
#include "fileoperation/napi_util.h"
#include "utils/log.h"
#include <fcntl.h>
#include <set>
#include <unordered_set>
#include <unistd.h>
#include <dirent.h>
#include <thread>

#include <filemanagement/fileio/oh_fileio.h>
#include <filemanagement/file_uri/oh_file_uri.h>

namespace {
const std::string CLOUD_PREFIX = "/data/storage/el2/cloud";
const size_t RETRY_COUNT = 100;  // 重试上限
}  // namespace

void *producer::FileProducer::producer(void *arg)
{
    FileProducer *instance = static_cast<FileProducer *>(arg);
    if (instance == nullptr) {
        return nullptr;
    }
    std::unordered_set<std::string> ignoreList = {".", ".."};
    int dir_fd = open(instance->folderPath.c_str(), O_RDONLY | O_DIRECTORY);
    if (dir_fd == -1) {
        OH_LOG_ERROR(LOG_APP, "producer open fail, error code: %{public}d", errno);
        instance->isProducerDone.store(true, std::memory_order_release);
        return nullptr;
    }
    DIR *dir = fdopendir(dir_fd);
    if (!dir) {
        OH_LOG_ERROR(LOG_APP, "producer dir error");
        close(dir_fd);
        instance->isProducerDone.store(true, std::memory_order_release);
        return nullptr;
    }
    struct dirent *entry;
    while ((entry = readdir(dir)) != nullptr && !instance->isProducerDone.load(std::memory_order_acquire)) {
        if (ignoreList.find(entry->d_name) != ignoreList.end()) {  // 忽略的文件名
            continue;
        }
        try {
            FileStat info{};
            if (fstatat(dir_fd, entry->d_name, &info.statInfo, 0) != 0) {
                continue;
            }
            info.fileName = entry->d_name;
            size_t retryCount = 0;  // 限制push重试次数
            while (!instance->fileQueue.push(info) && retryCount < RETRY_COUNT) {
                std::this_thread::yield();
                retryCount++;
            }
            if (retryCount == RETRY_COUNT) {
                OH_LOG_ERROR(LOG_APP, "producer retry too many");
                break;
            }
        } catch (const std::exception &err) {
            // 捕获其他标准异常
            OH_LOG_ERROR(LOG_APP, "producer file fail, error code: %{public}s", err.what());
            break;
        }
    }
    closedir(dir);  // 与OH专家定位发现closedir内有有close(fd),所以closedir后无需close(fd)
    OH_LOG_WARN(LOG_APP, "producer dir end");
    instance->isProducerDone.store(true, std::memory_order_release);
    return nullptr;
}

void producer::FileProducer::setParam(
    napi_env envIn, napi_value &callbackFuncIn, const std::string &folderPathIn, const size_t batchCountIn)
{
    this->env = envIn;
    this->callbackFunc = callbackFuncIn;
    this->folderPath = folderPathIn;
    if (batchCount <= 0) {
        this->batchCount = BATCH_SIZE_1W;
    } else {
        this->batchCount = batchCountIn;
    }
}

void producer::FileProducer::consumer()
{
    auto closeScope = [this](napi_handle_scope scope) { napi_close_handle_scope(env, scope); };
    napi_handle_scope scope = nullptr;  // scope 开始
    napi_open_handle_scope(env, &scope);
    if (scope == nullptr) {
        return;
    }
    std::unique_ptr<napi_handle_scope__, decltype(closeScope)> scopes(scope, closeScope);
    napi_value fileInfoListNapi = nullptr;
    napi_create_array(this->env, &fileInfoListNapi);
    uint32_t indexFileNapi = 0;
    FileStat info;
    bool isContinue = true;
    while (isContinue) {
        while (fileQueue.pop(info)) {
            napi_value fileNapi = getFileInfoNapi(info);
            if (fileNapi == nullptr) {
                OH_LOG_ERROR(LOG_APP, "get file napi info failed");
                continue;
            }
            napi_set_element(this->env, fileInfoListNapi, indexFileNapi++, fileNapi);
            if (indexFileNapi < this->batchCount) {
                continue;  // 卫语句,没满一批,不执行下面的回调
            }
            isContinue = returnResult(fileInfoListNapi, false);
            napi_create_array(this->env, &fileInfoListNapi);
            indexFileNapi = 0;  // 重置索引
            if (!isContinue) {
                this->isProducerDone.store(true, std::memory_order_release);  // 提前结束查询
                break;
            }
        }
        if (this->isProducerDone.load(std::memory_order_acquire) && this->fileQueue.isFinish()) {
            break;
        }
        std::this_thread::yield();
    }
    returnResult(fileInfoListNapi, true);
}

bool producer::FileProducer::returnResult(napi_value fileInfoList, bool isFinish)
{
    uint32_t status = napi_ok;
    napi_value isFinishNapi;
    status |= napi_get_boolean(this->env, isFinish, &isFinishNapi);
    napi_value returnParam[] = {fileInfoList, isFinishNapi};
    napi_value undefinedNapi;
    status |= napi_get_undefined(this->env, &undefinedNapi);
    napi_value result;
    status |= napi_call_function(this->env, undefinedNapi, this->callbackFunc, PARAM_TWO, returnParam, &result);
    bool isContinue = false;
    status |= napi_get_value_bool(this->env, result, &isContinue);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "returnResult napi error, %{public}d", status);
        return false;
    }
    return isContinue;
}

napi_value producer::FileProducer::getFileInfoNapi(FileStat &fileInfo)
{
    napi_value fileInfoNapi;
    if (napi_create_object(env, &fileInfoNapi) != napi_ok) {
        return nullptr;
    }
    napi_value fileNameNapi;
    napi_value uriNapi;
    napi_value pathNapi;
    napi_value isFolderNapi;
    napi_value sizeNapi;   // 大小
    napi_value mtimeNapi;  // 修改时间
    napi_value ctimeNapi;  // 创建时间
    napi_value atimeNapi;  // 时间
    napi_value locationNapi;

    std::string fileName = fileInfo.fileName;           // 文件名
    std::string path = folderPath + fileInfo.fileName;  // 文件路径
    char *uriResult = nullptr;
    FileManagement_ErrCode ret = OH_FileUri_GetUriFromPath(path.c_str(), path.length(), &uriResult);
    if (ret != ERR_OK || uriResult == nullptr) {
        OH_LOG_ERROR(LOG_APP, "GetUriFromPath error, %{public}d", ret);
        if (uriResult != nullptr) {
            free(uriResult);
        }
        return nullptr;
    }
    FileIO_FileLocation location = FileUtil::startsWith(path, CLOUD_PREFIX) ? FileUtil::getCloudFileLocation(uriResult)
                                                                            : FileIO_FileLocation::LOCAL;
    bool isFolder = S_ISDIR(fileInfo.statInfo.st_mode);  // 是否文件夹
    napi_create_string_utf8(env, uriResult, strlen(uriResult), &uriNapi);
    if (uriResult != nullptr) {
        free(uriResult);
    }
    napi_create_string_utf8(env, fileName.c_str(), fileName.length(), &fileNameNapi);
    napi_create_string_utf8(env, path.c_str(), path.length(), &pathNapi);
    napi_get_boolean(env, isFolder, &isFolderNapi);
    napi_create_int64(env, static_cast<int64_t>(fileInfo.statInfo.st_size), &sizeNapi);
    napi_create_int64(env, static_cast<int64_t>(fileInfo.statInfo.st_mtime), &mtimeNapi);
    napi_create_int64(env, static_cast<int64_t>(fileInfo.statInfo.st_ctime), &ctimeNapi);
    napi_create_int64(env, static_cast<int64_t>(fileInfo.statInfo.st_atime), &atimeNapi);
    napi_create_int32(env, static_cast<int32_t>(location), &locationNapi);

    napi_property_descriptor exportObjs[] = {
        // 对应文管FileInfo的对象字段
        DECLARE_NAPI_PROPERTY("fileName", fileNameNapi),
        DECLARE_NAPI_PROPERTY("relativePath", pathNapi),
        DECLARE_NAPI_PROPERTY("uri", uriNapi),
        DECLARE_NAPI_PROPERTY("isFolder", isFolderNapi),
        DECLARE_NAPI_PROPERTY("size", sizeNapi),
        DECLARE_NAPI_PROPERTY("mtime", mtimeNapi),
        DECLARE_NAPI_PROPERTY("ctime", ctimeNapi),
        DECLARE_NAPI_PROPERTY("addedDate", atimeNapi),
        DECLARE_NAPI_PROPERTY("locationType", locationNapi),
    };
    napi_define_properties(env, fileInfoNapi, sizeof(exportObjs) / sizeof(exportObjs[0]), exportObjs);
    return fileInfoNapi;
}

void producer::FileProducer::start()
{
    std::thread producer_thread(FileProducer::producer, this);
    consumer();
    producer_thread.join();
}

bool producer::FileProducer::getFileInfoListHandle(
    napi_env envIn, std::string &folderPathIn, size_t batchCountIn, napi_value &callbackFuncIn)
{
    std::shared_ptr<FileProducer> filePro = std::make_shared<FileProducer>();
    filePro->setParam(envIn, callbackFuncIn, folderPathIn, batchCountIn);
    filePro->start();
    return true;
}

napi_value NAPI_queryFiles(napi_env env, napi_callback_info info)
{
    OH_LOG_INFO(LOG_APP, "queryFiles start");
    size_t paramIndex = 0;      // 入参索引下标
    size_t argc = PARAM_THREE;  // 入参数量
    napi_value args[PARAM_THREE];
    if (napi_get_cb_info(env, info, &argc, args, nullptr, nullptr) != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "napi_get_cb_info failed");
        return nullptr;
    }

    napi_value trueBool;
    napi_value falseBool;
    napi_get_boolean(env, true, &trueBool);
    napi_get_boolean(env, false, &falseBool);

    auto closeScope = [env](napi_handle_scope scope) { napi_close_handle_scope(env, scope); };
    napi_handle_scope scope = nullptr;  // scope 开始
    napi_open_handle_scope(env, &scope);
    if (scope == nullptr) {
        return falseBool;
    }
    std::unique_ptr<napi_handle_scope__, decltype(closeScope)> scopes(scope, closeScope);
    std::string folderPath;
    int64_t batchCount = BATCH_SIZE_1W;    // 批次数量,默认1W
    napi_ref fileQueryCallBack = nullptr;  // 回调函数
    NapiUtil::parseJsStringProperty(env, args[paramIndex++], folderPath);
    if (!FileUtil::GetRealPath(folderPath)) {
        OH_LOG_ERROR(LOG_APP, "invalid path");
        return falseBool;
    }
    folderPath = FileUtil::getPathWithTrailingSlash(folderPath);
    napi_get_value_int64(env, args[paramIndex++], &batchCount);
    napi_create_reference(env, args[paramIndex++], 1, &fileQueryCallBack);
    if (fileQueryCallBack == nullptr) {
        OH_LOG_ERROR(LOG_APP, "fileCallBack is null");
        return falseBool;
    }
    napi_value callbackFunc;
    napi_get_reference_value(env, fileQueryCallBack, &callbackFunc);
    if (callbackFunc == nullptr || !FileUtil::isValidFolder(folderPath)) {
        OH_LOG_ERROR(LOG_APP, "callbackFunc is null or not exists folder");
        napi_delete_reference(env, fileQueryCallBack);
        return falseBool;
    }
    bool res = producer::FileProducer::getFileInfoListHandle(env, folderPath, batchCount, callbackFunc);
    napi_delete_reference(env, fileQueryCallBack);
    if (!res) {
        return falseBool;
    }
    return trueBool;
}