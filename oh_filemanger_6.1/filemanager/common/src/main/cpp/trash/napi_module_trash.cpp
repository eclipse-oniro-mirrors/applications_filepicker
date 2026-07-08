/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "napi_module_trash.h"

#include <string>
#include <unistd.h>
#include <uv.h>
#include <thread>
#include <memory>
#include <filesystem>
#include <ctime>
#include <sstream>
#include <iostream>
#include <deque>
#include <sys/types.h>
#include <sys/xattr.h>
#include <dirent.h>
#include <stack>

#include "napi/n_async_work_promise.h"
#include "napi/n_func_arg.h"
#include "napi/n_val.h"
#include "utils/log.h"

#include "file_manager_utils.h"
#include "trash_data_struct.h"
#include "trash_utils.h"
#include "filemanager_rdb_trash.h"

namespace OHOS {
namespace FileManager {

const std::string TRASH = "/.trash";
const std::string CLOUD_TRASH_KEY = "user.cloud.recycle";
const std::string CLOUD_FILE_DELETE_TIME_KEY = "user.cloud.deletetime";
const std::string CLOUD_TRASH_PATH_KEY = "user.cloud.recyclePath";
const std::string OLD_RECYCLE_BIN_PATH = "/storage/Users/currentUser/UpdateBackup/.File_Recycle";
const std::string TO_RECOVER_RECYCLE_BIN_PATH = "/storage/Users/currentUser/UpdateBackup/RecycleBin";
const std::string HW_RECYCLE_CONTENT = "hw_recycle_content";
const std::string NO_MEDIA = ".nomedia";
const std::string CATEGORY = "category";
const std::string DELETE_VALUE = "1";
const std::string RECOVER_VALUE = "0";
const int32_t ATTR_VALUE_INIT_SIZE = 100;
const int32_t RECYCLE_MAX_SIZE = 512;

static bool GenerateFileInfoEntity(FileInfo& fileInfoEntity, std::string filterDirent,
    int64_t timeSlot, std::string realFilePath)
{
    size_t lastSlashPos = filterDirent.find_last_of("/");
    if (lastSlashPos == std::string::npos) {
        HILOGE("Invalid path");
        return false;
    }

    fileInfoEntity.srcPath = realFilePath;
    fileInfoEntity.trashFileName = filterDirent.substr(lastSlashPos + 1);
    fileInfoEntity.uri = filterDirent;
    if (FileManagerUtils::StartsWith(filterDirent, CLOUD_DRIVE_BASE_PATH)) {
        auto pos = fileInfoEntity.trashFileName.find_last_of("_");
        if (pos == std::string::npos) {
            fileInfoEntity.fileName = fileInfoEntity.trashFileName;
        } else {
            fileInfoEntity.fileName = fileInfoEntity.trashFileName.substr(0, pos);
        }
    } else {
        auto pos = realFilePath.find_last_of("/");
        if (pos != std::string::npos) {
            fileInfoEntity.fileName = realFilePath.substr(pos + 1);
        } else {
            fileInfoEntity.fileName = fileInfoEntity.trashFileName;
        }
    }

    size_t uMode = SUPPORTS_READ | SUPPORTS_WRITE;
    StatEntity statEntity;
    if (TrashUtils::GetStat(filterDirent, statEntity)) {
        bool check = (statEntity.stat_.st_mode & S_IFMT) == S_IFDIR;
        if (check) {
            uMode |= REPRESENTS_DIR;
        } else {
            uMode |= REPRESENTS_FILE;
        }
        HILOGD("After filter mode  = %{public}zu", uMode);
        fileInfoEntity.mode = static_cast<int32_t>(uMode);

        fileInfoEntity.size = static_cast<int64_t>(statEntity.stat_.st_size);
        fileInfoEntity.mtime = static_cast<int64_t>(statEntity.stat_.st_mtime);
        fileInfoEntity.ctime = static_cast<int64_t>(statEntity.stat_.st_ctime);
        fileInfoEntity.deleteTime = timeSlot;
    }
    return true;
}

static napi_value CreateFileInfoObject(napi_env env, FileInfo fileInfo)
{
    uint32_t status = napi_ok;
    napi_value resultVal;
    status |= napi_create_object(env, &resultVal);
    napi_value tmpVal;
    status |= napi_create_string_utf8(env, fileInfo.uri.c_str(), fileInfo.uri.length(), &tmpVal);
    status |= napi_set_named_property(env, resultVal, "uri", tmpVal);
    status |= napi_create_string_utf8(env, fileInfo.srcPath.c_str(), fileInfo.srcPath.length(), &tmpVal);
    status |= napi_set_named_property(env, resultVal, "srcPath", tmpVal);
    status |= napi_create_string_utf8(env, fileInfo.fileName.c_str(), fileInfo.fileName.length(), &tmpVal);
    status |= napi_set_named_property(env, resultVal, "fileName", tmpVal);
    status |= napi_create_int64(env, fileInfo.mode, &tmpVal);
    status |= napi_set_named_property(env, resultVal, "mode", tmpVal);
    status |= napi_create_int64(env, fileInfo.size, &tmpVal);
    status |= napi_set_named_property(env, resultVal, "size", tmpVal);
    status |= napi_create_int64(env, fileInfo.mtime, &tmpVal);
    status |= napi_set_named_property(env, resultVal, "mtime", tmpVal);
    status |= napi_create_int64(env, fileInfo.ctime, &tmpVal);
    status |= napi_set_named_property(env, resultVal, "ctime", tmpVal);
    status |= napi_create_int64(env, fileInfo.deleteTime, &tmpVal);
    status |= napi_set_named_property(env, resultVal, "deleteTime", tmpVal);
    if (status != napi_ok) {
        HILOGE("Create CopyResult object error");
        return nullptr;
    }
    return resultVal;
}

static int64_t getDeleteTimeAttr(const std::string &path)
{
    HILOGI("getDeleteTimeAttr enter");
    int64_t timeSlot = 0;
    char attrValue[ATTR_VALUE_INIT_SIZE] = {0};
    size_t attrValueSize = sizeof(attrValue);
    int getAttrRet = getxattr(path.c_str(),
        CLOUD_FILE_DELETE_TIME_KEY.c_str(), attrValue, attrValueSize);
    if (getAttrRet != E_FILEMGR_ERR && getAttrRet < ATTR_VALUE_INIT_SIZE) {
        attrValue[getAttrRet] = '\0';
        int32_t convertRet = 0;
        std::string attrValueStr(attrValue);
        const uint32_t fixLength = 13;
        if (attrValueStr.length() == fixLength) {
            const int lastDigit = 3;
            attrValueStr = attrValueStr.substr(0, attrValueStr.length() - lastDigit);
        } else {
            HILOGE("AttrValue fixLength error. attrValue : %{public}s", attrValue);
        }
        bool hasConveted = FileManagerUtils::ConvertStrToInt32(attrValueStr, convertRet);
        if (hasConveted) {
            timeSlot = static_cast<int64_t>(convertRet);
        } else {
            HILOGE("Convert attrValue to time error. attrValue : %{public}s", attrValue);
        }
    } else {
        HILOGE("ListTrashFile getxattr deleteTime error : %{public}s", strerror(errno));
    }

    HILOGI("getDeleteTimeAttr end");
    return timeSlot;
}

static std::string GetCloudUriOrUriByPath(const std::string &path)
{
    if (path.size() == 0) {
        HILOGE("path is empty");
        return path;
    }
    return TrashUtils::GetUriByPath(path);
}

napi_value TrashNapi::DeleteToTrash(napi_env env, napi_callback_info info)
{
    HILOGI("TrashNapi::DeleteToTrash enter");
    FileManagerCommon::NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(FileManagerCommon::NARG_CNT::ZERO, FileManagerCommon::NARG_CNT::ONE)) {
        HILOGE("Number of arguments mismatched");
        NError(E_PARAM).ThrowErr(env);
        return nullptr;
    }

    std::string originalUri = FileManagerCommon::NVal(env, funcArg[FileManagerCommon::NARG_POS::FIRST]).GetStringParam();
    int32_t ret = E_FILEMGR_OK;
    auto trashPathPtr = std::make_shared<std::string>();
    std::string userId = FileManagerUtils::GetVerifyUserId();
    std::string uri = FileManagerUtils::Decode(originalUri);
    if (FileManagerUtils::StartsWith(uri, FileConsts::FAF_URI_BASE)) {
        ret = TrashUtils::DeleteToTrash(userId, uri, *trashPathPtr, true);
    } else if (FileManagerUtils::StartsWith(uri, FileConsts::EXTERNAL_URI_BASE)) {
        return DeleteCompletely(env, info);
    } else {
        HILOGE("Invalid uri");
        ret = E_PARAM;
    }

    auto cbExec = [ret, originalUri, trashPathPtr](napi_env env) -> NError {
        return NError(ret);
    };

    auto cbComplete = [originalUri, trashPathPtr](napi_env env, NError err) -> FileManagerCommon::NVal {
        if (err) {
            return {env, err.GetNapiErr(env)};
        }
        std::string resUri = GetCloudUriOrUriByPath(*trashPathPtr);
        HILOGI("TrashNapi::DeleteToTrash end");
        return FileManagerCommon::NVal::CreateUTF8String(env, resUri);
    };

    FileManagerCommon::NVal thisVar(env, funcArg.GetThisVar());
    return NAsyncWorkPromise(env, thisVar).Schedule("deleteToTrash_", cbExec, cbComplete).val_;
}

static std::string RecurCheckIfOnlyContentInDir(const std::string &path, size_t trashWithTimePos,
    const std::string &trashWithTimePath)
{
    HILOGD("RecurCheckIfOnlyContentInDir");
    size_t slashPos = path.find_last_of("/");
    if (slashPos <= trashWithTimePos) {
        HILOGD("RecurCheckIfOnlyContentInDir: slashPos = %{public}zu", slashPos);
        return trashWithTimePath;
    }
    std::string parentPath = path.substr(0, slashPos);
    int num = TrashUtils::ScanDir(parentPath);
    HILOGD("RecurCheckIfOnlyContentInDir: num = %{public}d", num);
    if (num > 1) {
        // 同一时间戳目录下存在多个删除项，则不论是还原后的删除还是彻底删除，仅需删除该项
        HILOGD("RecurCheckIfOnlyContentInDir: find other items in current dir");
        return path;
    } else if (num == 1) {
        // 需要向上一层目录判断
        return RecurCheckIfOnlyContentInDir(parentPath, trashWithTimePos, trashWithTimePath);
    } else {
        HILOGE("RecurCheckIfOnlyContentInDir error.");
    }
    return nullptr;
}

static bool IsMkdirFileRestore(const std::string &sourcePath)
{
    if (!FileManagerUtils::StartsWith(sourcePath, SANDBOX_DIR_EL1_BASE_PATH) &&
        !FileManagerUtils::StartsWith(sourcePath, SANDBOX_DIR_EL2_BASE_PATH)) {
        return false;
    }
    std::string tmpPath = sourcePath;
    std::string appName = tmpPath.replace(0, SANDBOX_DIR_EL1_BASE_PATH.size() + 1, "");
    size_t pos = appName.find_first_of("/");
    if (pos == std::string::npos) {
        HILOGI("do not need mkdir file restore.");
        return false;
    }
    appName = appName.substr(0, pos);
    std::string path;
    if (FileManagerUtils::StartsWith(sourcePath, SANDBOX_DIR_EL1_BASE_PATH)) {
        path = SANDBOX_DIR_EL1_BASE_PATH + "/" + appName;
    } else {
        path = SANDBOX_DIR_EL2_BASE_PATH + "/" + appName;
    }
    if (access(path.c_str(), 0) != 0) {
        HILOGI("path not exit");
        return true;
    }
    return false;
}

static napi_value NotifyTrashRecoverEvent(napi_env env, const std::string &filePath, const std::string &sourceFilePath)
{
    std::string fileUri = TrashUtils::GetUriByPath(filePath);
    HILOGD("NotifyTrashRecoverEvent");
    return FileManagerCommon::NVal::CreateUTF8String(env, sourceFilePath).val_;
}

static napi_value RecoverFile(napi_env env, const std::string &filePath, std::string &sourceFilePath)
{
    bool isMkdirFileRestore = IsMkdirFileRestore(sourceFilePath);
    size_t pos = sourceFilePath.find_last_of("/");
    if (isMkdirFileRestore) {
        if (!FileManagerUtils::Mkdir(FILE_RESTORE_PATH)) {
            HILOGE("RecoverFile: Mkdir failed");
            NError(E_MKDIR_FAILED).ThrowErr(env);
            return nullptr;
        }
        std::string fileName = sourceFilePath.substr(pos + 1);
        sourceFilePath = FILE_RESTORE_PATH + "/" + fileName;
    } else {
        if (sourceFilePath.length() == 0 || pos == std::string::npos ||
            !FileManagerUtils::Mkdir(sourceFilePath.substr(0, pos))) {
            HILOGE("RecoverFile: Mkdir failed");
            NError(E_MKDIR_FAILED).ThrowErr(env);
            return nullptr;
        }
    }

    int moveRet = TrashUtils::MoveFile(filePath, sourceFilePath, true);
    if (moveRet != E_FILEMGR_OK) {
        HILOGE("RecoverFile: MoveFile failed");
        NError(moveRet).ThrowErr(env);
        return nullptr;
    }
    std::string userId = FileManagerUtils::GetVerifyUserId();
    FileManagerRdbTrash(userId).DeleteFromTrash({ filePath });
    return NotifyTrashRecoverEvent(env, filePath, sourceFilePath);
}

static napi_value RecoverDir(napi_env env, const std::string &dirPath, const std::string &srcDirPath)
{
    
    std::string srcParentPath = FileManagerUtils::GetParentPath(srcDirPath);
    auto [isExist, _] = TrashUtils::Access(srcParentPath);
    if (!isExist && !FileManagerUtils::Mkdir(srcParentPath)) {
        HILOGE("RecoverDir: Mkdir failed");
        NError(E_MKDIR_FAILED).ThrowErr(env);
        return nullptr;
    }

    std::deque<struct ErrFiles> errfiles;
    int result = TrashUtils::MoveDir(dirPath, srcDirPath, DIRMODE_DIRECTORY_REPLACE, errfiles);
    if (result != E_FILEMGR_OK) {
        HILOGE("RecoverFile: MoveDir failed");
        NError(result).ThrowErr(env);
        return FileManagerCommon::NVal::CreateUndefined(env).val_;
    }
    std::string userId = FileManagerUtils::GetVerifyUserId();
    FileManagerRdbTrash(userId).DeleteFromTrash({ dirPath });
    return NotifyTrashRecoverEvent(env, dirPath, srcDirPath);
}

bool CheckRecoverPath(napi_env &env, const std::string &path, const std::string &userId)
{
    if (path.find(TRASH_PATH) == std::string::npos) {
        NError(E_INVALID_PATH).ThrowErr(env);
        HILOGE("Recover: path is not trash path");
        return false;
    }

    auto [isExist, _] = TrashUtils::Access(path);
    if (!isExist) {
        NError(E_FILE_FILE_NOT_EXIST).ThrowErr(env);
        HILOGE("Recover: Path is not exist");
        // 根据回收站路径去数据库查询原路径
        std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashInfoByTrashPath({ path });
        FileManagerRdbTrash(userId).DeleteFromTrash({ path });
        if (trashInfos.size() == 1) {
            NotifyTrashRecoverEvent(env, path, trashInfos[0].srcPath);
        }
        return false;
    }
    return true;
}

napi_value TrashNapi::Recover(napi_env env, napi_callback_info info)
{
    HILOGI("Recover enter");

    FileManagerCommon::NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(FileManagerCommon::NARG_CNT::ZERO, FileManagerCommon::NARG_CNT::ONE)) {
        HILOGE("Number of arguments mismatched");
        NError(EINVAL).ThrowErr(env);
        return nullptr;
    }

    std::string uri = FileManagerUtils::Decode(FileManagerCommon::NVal(env, funcArg[FileManagerCommon::NARG_POS::FIRST]).GetStringParam());
    std::string path = uri;
    std::string userId = FileManagerUtils::GetVerifyUserId();
    if (!TrashUtils::GetRealPath(path)) {
        NError(E_INVALID_PATH).ThrowErr(env);
        HILOGE("Invalid path");
        // 根据回收站路径去数据库查询原路径
        std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashInfoByTrashPath({ path });
        FileManagerRdbTrash(userId).DeleteFromTrash({ path });
        if (trashInfos.size() == 1) {
            NotifyTrashRecoverEvent(env, path, trashInfos[0].srcPath);
        }
        return nullptr;
    }

    if (!CheckRecoverPath(env, path, userId)) {
        HILOGE("CheckRecoverPath fail");
        return nullptr;
    }

    // 根据回收站路径去数据库查询原路径
    std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashInfoByTrashPath({ path });
    if (trashInfos.size() != 1) {
        HILOGE("trashInfos size: %{public}zu", trashInfos.size());
        NError(E_DB_QUERY_FAILED).ThrowErr(env);
        return nullptr;
    }

    return TrashUtils::CheckDir(path) ? RecoverDir(env, path, trashInfos[0].srcPath) :
                                        RecoverFile(env, path, trashInfos[0].srcPath);
}

napi_value TrashNapi::RecoverFileToSpecifiedDir(napi_env env, napi_callback_info info)
{
    HILOGD("RecoverFileToSpecifiedDir enter");

    FileManagerCommon::NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(FileManagerCommon::NARG_CNT::TWO, FileManagerCommon::NARG_CNT::TWO)) {
        HILOGE("Number of arguments mismatched");
        NError(EINVAL).ThrowErr(env);
        return nullptr;
    }

    std::string trashFileUri = FileManagerCommon::NVal(env, funcArg[FileManagerCommon::NARG_POS::FIRST]).GetStringParam();
    trashFileUri = FileManagerUtils::Decode(trashFileUri);

    // 获取到uri对应的真是路径
    std::string path = trashFileUri.replace(0, FileConsts::FAF_URI_BASE.size(), FileConsts::FAF_FOLDER_BASE);
    if (!TrashUtils::GetRealPath(path)) {
        NError(EINVAL).ThrowErr(env);
        HILOGE("Invalid path");
        return nullptr;
    }

    std::string recoverToUri = FileManagerCommon::NVal(env, funcArg[FileManagerCommon::NARG_POS::SECOND]).GetStringParam();
    CHECK_AND_RETURN_RET_LOG(!TrashUtils::CheckDir(recoverToUri), FileManagerCommon::NVal::CreateUndefined(env).val_,
        "RecoverTo Directory can not be a file");
    // 根据回收站路径去数据库查询原路径
    std::string userId = FileManagerUtils::GetVerifyUserId();
    std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashInfoByTrashPath({ path });
    if (trashInfos.size() != 1) {
        NError(EINVAL).ThrowErr(env);
        HILOGE("trashInfos size: %{public}zu", trashInfos.size());
        return FileManagerCommon::NVal::CreateUndefined(env).val_;
    }

    size_t lastSlashPosition = trashInfos[0].srcPath.find_last_of("/");
    std::string lastPartPathName = trashInfos[0].srcPath.substr(lastSlashPosition + 1);
    std::string moveToPath = recoverToUri + "/" + lastPartPathName;
    auto [isExist, _] = TrashUtils::Access(moveToPath);
    if (isExist) {
        TrashUtils::GenerateNewPathOfRecover(moveToPath, GENERATE_NEW_NAME_START_NUMBER);
    }

    if (!TrashUtils::CheckDir(path)) {
        return RecoverFile(env, path, moveToPath);
    }
    return RecoverDir(env, path, moveToPath);
}

static napi_value CreateObjectArray(napi_env env, std::vector<FileInfo> result)
{
    uint32_t status = napi_ok;
    napi_value fileInfoResultArray = nullptr;
    status = napi_create_array_with_length(env, result.size(), &fileInfoResultArray);
    if (status != napi_ok) {
        HILOGE("Create napi array fail");
        return nullptr;
    }

    for (size_t i = 0; i < result.size(); i++) {
        FileInfo &tmpResult = result.at(i);
        napi_value resultVal = CreateFileInfoObject(env, tmpResult);
        status |= napi_set_element(env, fileInfoResultArray, i, resultVal);
        if (status != napi_ok) {
            HILOGE("Create CopyResult object error");
            return nullptr;
        }
    }
    return fileInfoResultArray;
}

static std::string GetTimeSlotFromPath(const std::string &path)
{
    size_t slashSize = 1;
    // 获取时间戳
    size_t trashPathPrefixPos = path.find(TRASH_PATH);
    size_t expectTimeSlotStartPos = trashPathPrefixPos + TRASH_PATH.length() + slashSize;
    if (expectTimeSlotStartPos >= path.length()) {
        return "";
    }
    std::string realFilePathWithTime = path.substr(trashPathPrefixPos + TRASH_PATH.length() + slashSize);
    // 获取时间戳目录位置
    size_t trashPathWithTimePrefixPos = realFilePathWithTime.find_first_of("/");
    if (trashPathWithTimePrefixPos == std::string::npos) {
        HILOGE("GetTimeSlotFromPath: Invalid path");
        return "";
    }
    std::string timeSlot = realFilePathWithTime.substr(0, trashPathWithTimePrefixPos);
    HILOGD("GetTimeSlotFromPath: timeSlot = %{public}s", timeSlot.c_str());
    return timeSlot;
}

static int RecursiveFunc(const std::string &path, std::vector<std::string> &dirents)
{
    std::unique_ptr<struct NameListArg, decltype(TrashUtils::Deleter)*> pNameList
        = { new (std::nothrow) struct NameListArg, TrashUtils::Deleter };
    if (!pNameList) {
        HILOGE("Failed to request heap memory.");
        return ENOMEM;
    }
    HILOGD("RecursiveFunc: scandir start");
    int num = scandir(path.c_str(), &(pNameList->namelist), TrashUtils::FilterFunc, alphasort);
    if (num < 0) {
        HILOGE("RecursiveFunc: Failed to scan dir");
        return errno;
    }
    pNameList->direntNum = num;
    std::string pathInRecur = path;
    for (int i = 0; i < num; i++) {
        if ((*(pNameList->namelist[i])).d_type == DT_REG) {
            dirents.emplace_back(path + '/' + pNameList->namelist[i]->d_name);
        } else if ((*(pNameList->namelist[i])).d_type == DT_DIR) {
            std::string pathTemp = pathInRecur;
            pathInRecur += '/' + std::string((*(pNameList->namelist[i])).d_name);
            // check if path include TRASH_SUB_DIR + "/", need to add it into dirents
            HILOGD("RecursiveFunc start");
            std::string timeSlot = GetTimeSlotFromPath(pathTemp);
            if (!timeSlot.empty() && pathInRecur.rfind(TRASH_SUB_DIR + timeSlot + "/") != std::string::npos) {
                // Only filter previous dir is TRASH_SUB_DIR
                dirents.emplace_back(pathInRecur);
            }
            int ret = RecursiveFunc(pathInRecur, dirents);
            if (ret != E_FILEMGR_OK) {
                HILOGE("RecursiveFunc: Failed to recursive get all dirents for %{public}d", ret);
                return ret;
            }
            pathInRecur = pathTemp;
        }
    }
    return E_FILEMGR_OK;
}

napi_value TrashNapi::ListTrashFile(napi_env env, napi_callback_info info)
{
    HILOGI("ListTrashFile enter.");

    FileManagerCommon::NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(FileManagerCommon::NARG_CNT::ZERO)) {
        HILOGE("Number of arguments mismatched");
        NError(EINVAL).ThrowErr(env);
        return nullptr;
    }

    std::vector<FileInfo> fileInfoList;
    std::string userId = FileManagerUtils::GetVerifyUserId();
    std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashes();
    for (size_t i = 0; i < trashInfos.size(); i++) {
        FileInfo info;
        GenerateFileInfoEntity(info, trashInfos[i].trashPath, trashInfos[i].deleteTime, trashInfos[i].srcPath);
        fileInfoList.emplace_back(info);
    }
    HILOGI("trashInfos size = %{public}zu", trashInfos.size());
    
    HILOGI("ListTrashFile end.");
    return CreateObjectArray(env, fileInfoList);
}

static int32_t DeleteByUri(const std::string &uri)
{
    std::string path = uri;
    std::string userId = FileManagerUtils::GetVerifyUserId();
    if (!TrashUtils::GetRealPath(path)) {
        HILOGE("completelyDelete: Invalid Path");
        FileManagerRdbTrash(userId).DeleteFromTrash(path);
        return E_FILE_FILE_NOT_EXIST;
    }
 
    if (path.find(TRASH_PATH) == std::string::npos) {
        HILOGE("completelyDelete: path is not Trash path");
        return E_FILEMGR_ERR;
    }
 
    auto [isExist, _] = TrashUtils::Access(path);
    if (!isExist) {
        HILOGE("completelyDelete: Path is not exist");
        FileManagerRdbTrash(userId).DeleteFromTrash(path);
        return E_FILEMGR_ERR;
    }

    int32_t res = E_FILEMGR_ERR;
    if (TrashUtils::CheckDir(path)) {
        res = TrashUtils::RmDirectory(path);
    } else {
        res = FileManagerUtils::RemovePath(path);
    }

    if (res == E_FILEMGR_OK) {
        FileManagerRdbTrash(userId).DeleteFromTrash(path);
    }
    return res;
}

napi_value TrashNapi::DeleteCompletely(napi_env env, napi_callback_info info)
{
    HILOGI("DeleteCompletely enter.");

    FileManagerCommon::NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(FileManagerCommon::NARG_CNT::ONE)) {
        HILOGE("Number of arguments mismatched");
        NError(EINVAL).ThrowErr(env);
        return nullptr;
    }

    std::string uriParam = FileManagerCommon::NVal(env, funcArg[FileManagerCommon::NARG_POS::FIRST]).GetStringParam();
    std::string uri = FileManagerUtils::Decode(uriParam);
    int32_t ret = E_FILEMGR_ERR;
    ret = DeleteByUri(uri);

    if (ret == E_FILEMGR_OK) {
        HILOGD("NotifyTrashEvent");
    } else {
        if (ret == ENOENT || ret == E_FILE_FILE_NOT_EXIST) {
            NError(E_FILE_FILE_NOT_EXIST).ThrowErr(env);
        } else {
            NError(EINVAL).ThrowErr(env);
        }
    }
    HILOGI("DeleteCompletely end.");
    return FileManagerCommon::NVal::CreateUndefined(env).val_;
}

static int32_t DeleteToTrashForUpgrade(std::string &path)
{
    HILOGI("DeleteToTrashForUpgrade enter.");
    auto [isExist, _] = TrashUtils::Access(TRASH_PATH);
    if (!isExist) {
        bool trashPathMade = FileManagerUtils::Mkdir(TRASH_PATH);
        if (!trashPathMade) {
            return E_MKDIR_FAILED;
        }
    }

    std::string fileName = FileManagerUtils::GetFileNameFromUri(path);
    if (fileName == "") {
        HILOGE("Get fileName error.");
        return E_FILEMGR_ERR;
    }
    std::string moveFrom = path;
    std::string moveTo = TRASH_PATH + "/" + fileName;
    auto [isMoveToExist, moveRet] = TrashUtils::Access(moveTo);
    if (isMoveToExist) {
        TrashUtils::GenerateNewPath(moveTo);
    }

    TrashInfo info;
    info.srcPath = TO_RECOVER_RECYCLE_BIN_PATH + "/" + fileName;
    info.trashPath = moveTo;
    info.deleteTime = FileManagerUtils::GetTimeStamp();
    int32_t ret = FileManagerRdbTrash().AddToTrash(info);
    if (ret != E_FILEMGR_OK) {
        HILOGE("AddToTrash error.");
        return E_DB_INSERT_FAILED;
    }

    if (TrashUtils::CheckDir(path)) {
        std::deque<struct ErrFiles> errfiles;
        moveRet = TrashUtils::MoveDir(moveFrom, moveTo, DIRMODE_DIRECTORY_REPLACE, errfiles);
    } else {
        moveRet = TrashUtils::MoveFile(path, moveTo, false);
    }

    if (moveRet != E_FILEMGR_OK) {
        HILOGE("Move failed: %{public}d", moveRet);
        std::string userId = FileManagerUtils::GetVerifyUserId();
        FileManagerRdbTrash(userId).DeleteFromTrash({ moveTo });
    }
    HILOGI("DeleteToTrashForUpgrade end.");
    return moveRet;
}

static int32_t ProcessFileInOldRecyclingBin(std::string &path)
{
    HILOGI("Process file in old recycle bin enter.");
    std::stack<std::string> dirStack;
    dirStack.push(path);
    int32_t ret = E_FILEMGR_OK;
    int32_t processRet = E_FILEMGR_OK;
    while (!dirStack.empty()) {
        path = dirStack.top();
        dirStack.pop();
        if (!TrashUtils::CheckDir(path)) {
            processRet = DeleteToTrashForUpgrade(path);
            if (processRet != E_FILEMGR_OK) {
                ret = processRet;
                HILOGE("Delete file to trash failed: %{public}d", processRet);
            }
            continue;
        }

        std::vector<std::string> dirents;
        processRet = TrashUtils::GetFilesInCurrentDir(path, dirents);
        if (processRet != E_FILEMGR_OK) {
            HILOGE("Failed to get files in current dir : %{public}d", processRet);
            ret = processRet;
            continue;
        }

        std::string fileNameOnly = FileManagerUtils::GetFileNameFromUri(path);
        if (fileNameOnly == "") {
            HILOGE("Get fileName error.");
            return E_FILEMGR_ERR;
        }
        if (fileNameOnly != HW_RECYCLE_CONTENT) {
            for (auto &dirent : dirents) {
                dirStack.push(dirent);
            }
            continue;
        }

        for (auto &dirent : dirents) {
            processRet = DeleteToTrashForUpgrade(dirent);
            if (processRet != E_FILEMGR_OK) {
                HILOGE("Delete file or dir to trash failed : %{public}d", processRet);
                ret = processRet;
            }
        }
    }
    HILOGI("Process file in old recycle bin end.");
    return ret;
}

napi_value TrashNapi::ProcessOldRecycleBinFiles(napi_env env, napi_callback_info info)
{
    HILOGI("Process old recycle bin files enter.");

    auto [isExist, _] = TrashUtils::Access(OLD_RECYCLE_BIN_PATH);
    if (!isExist) {
        HILOGI("RecycleBin not exist.");
        return FileManagerCommon::NVal::CreateUndefined(env).val_;
    }

    if (!TrashUtils::CheckDir(OLD_RECYCLE_BIN_PATH)) {
        HILOGI("RecycleBinPath is not a directory.");
        return FileManagerCommon::NVal::CreateUndefined(env).val_;
    }

    std::vector<std::string> dirents;
    int result = TrashUtils::GetFilesInCurrentDir(OLD_RECYCLE_BIN_PATH, dirents);
    if (result != E_FILEMGR_OK) {
        HILOGE("Failed to get files in RecycleBin dir");
        return FileManagerCommon::NVal::CreateUndefined(env).val_;
    }
    int removeResult = E_FILEMGR_OK;
    HILOGI("Dirents size : %{public}zu", dirents.size());
    for (size_t i = 0; i < dirents.size(); i++) {
        std::string filePath = dirents[i];
        if (filePath == OLD_RECYCLE_BIN_PATH + "/" + NO_MEDIA && !TrashUtils::CheckDir(filePath)) {
            continue;
        }
        if (filePath == OLD_RECYCLE_BIN_PATH + "/" + CATEGORY && TrashUtils::CheckDir(filePath)) {
            continue;
        }
        int dealFileResult = ProcessFileInOldRecyclingBin(filePath);
        if (dealFileResult != E_FILEMGR_OK) {
            result = dealFileResult;
        } else {
            removeResult = TrashUtils::RmDirectory(filePath);
            if (removeResult != E_FILEMGR_OK) {
                result = removeResult;
            }
        }
    }

    if (result != E_FILEMGR_OK) {
        HILOGE("Failed to deal with files in old recycle bin, resultCode : %{public}d", result);
    } else {
        TrashUtils::RmDirectory(OLD_RECYCLE_BIN_PATH);
    }
    HILOGI("Process old recycle bin files end.");
    return FileManagerCommon::NVal::CreateUndefined(env).val_;
}
} // namespace FileManager
} // namespace OHOS

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"recoverFile", nullptr, OHOS::FileManager::TrashNapi::Recover, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"recoverFileToSpecifiedDir", nullptr, OHOS::FileManager::TrashNapi::RecoverFileToSpecifiedDir,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteFile", nullptr, OHOS::FileManager::TrashNapi::DeleteToTrash,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteFile", nullptr, OHOS::FileManager::TrashNapi::DeleteToTrash,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"listTrashFile",
            nullptr,
            OHOS::FileManager::TrashNapi::ListTrashFile,
            nullptr,
            nullptr,
            nullptr,
            napi_default,
            nullptr},
        {"deleteCompletely", nullptr, OHOS::FileManager::TrashNapi::DeleteCompletely, nullptr, nullptr, nullptr, 
        napi_default, nullptr},
        {"processOldRecycleBinFiles", nullptr, OHOS::FileManager::TrashNapi::ProcessOldRecycleBinFiles, nullptr, 
        nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module TrashModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "Trash",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterTrashEntryModule(void)
{
    napi_module_register(&TrashModule);
}