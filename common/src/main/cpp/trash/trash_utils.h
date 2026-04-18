/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#ifndef OHOS_TRASH_UTILS_H
#define OHOS_TRASH_UTILS_H

#include <cstring>
#include <dirent.h>
#include <iostream>
#include <memory>
#include <sstream>
#include <string_view>
#include <sys/stat.h>
#include <unistd.h>
#include <deque>
#include <vector>


#include "trash_data_struct.h"
#include "file_manager_utils.h"
namespace OHOS {
namespace FileManager {

const size_t REPRESENTS_FILE = 1;
const size_t REPRESENTS_DIR = 1 << 1;
const size_t SUPPORTS_READ = 1 << 2;
const size_t SUPPORTS_WRITE = 1 << 3;

constexpr int DIR_DEFAULT_PERM = 0770;
constexpr int FILTER_MATCH = 1;
constexpr int FILTER_DISMATCH = 0;
constexpr int MILLISECOND_TO_SECOND = 1000;
const std::string TRASH_PATH = "/storage/Users/currentUser/.Trash";
const std::string TRASH_SUB_DIR = "oh_trash_content";
const std::string TRASH_SERVER_PATH_FIRST_PART = "/data/service/el2/";
const std::string TRASH_SERVER_PATH_LAST_PART = "/hmdfs/account/files/Docs/.Trash";
const std::string CLOUD_DRIVE_BASE_PATH = "/data/storage/el2/cloud";
const std::string SANDBOX_DIR_EL1_PATH = "/storage/Users/currentUser/appdata/el1";
const std::string SANDBOX_DIR_EL2_PATH = "/storage/Users/currentUser/appdata/el2";
const std::string SANDBOX_DIR_EL1_BASE_PATH = "/storage/Users/currentUser/appdata/el1/base";
const std::string SANDBOX_DIR_EL2_BASE_PATH = "/storage/Users/currentUser/appdata/el2/base";
const std::string FILE_RESTORE_PATH = "/storage/Users/currentUser/File_Restore";
const std::string EXTERNAL_STORAGE_PATH = "/storage/External/";
const std::string DLP = "dlp";
const int32_t GENERATE_NEW_NAME_START_NUMBER = 2;
const uint32_t CUT_FILE_NAME_LENGTH = 20;
const uint32_t TIME_SLOT_LENGTH = 13;

enum class TRASH_OPERATION {
    DELETE = 0,
    RECOVER,
    DELETE_COMPLETELY,
};

enum ModeOfMoveDir {
    DIRMODE_DIRECTORY_THROW_ERR = 0,
    DIRMODE_FILE_THROW_ERR,
    DIRMODE_FILE_REPLACE,
    DIRMODE_DIRECTORY_REPLACE
};

struct NameListArg {
    struct dirent **namelist = {nullptr};
    int direntNum = 0;
};

struct StatEntity {
    struct stat stat_;
};

struct DeleteTrashParam {
    const std::string userId = "";
    std::string path = "";
    int32_t posLastSlash = 0;
    bool isClient = false;
};

class TrashUtils {
public:
    static void Deleter(struct NameListArg *arg);
    static int32_t FilterFunc(const struct dirent *filename);
    static bool GetStat(const std::string &path, StatEntity &statEntity);
    static bool CheckDir(const std::string &path);
    static std::tuple<bool, int> Access(const std::string &path);
    static int RenameFile(const std::string &src, const std::string &dest);
    static int ScanDir(const std::string &path);
    static bool GetRealPath(std::string &path);
    static int RemovePath(const std::string &pathStr);
    static int
        RenameFile(const std::string &src, const std::string &dest, int mode, std::deque<struct ErrFiles> &errfiles);
    static int32_t
        MoveDir(const std::string &src, const std::string &dest, int mode, std::deque<struct ErrFiles> &errfiles);
    static void GenerateNewFilePath(std::string &filePath);
    static void GenerateNewDir(std::string &filePath);
    static std::string GetUriByPath(const std::string &path);
    static void ProcessOldFileInTrash(const std::string &userId);
    static int MoveFile(const std::string &srcFile, const std::string &destFile, bool isRecover);
    static bool GenerateFileInfoEntity(FileInfo& fileInfoEntity,
        std::string filterDirent, int64_t timeSlot, std::string realFilePath);
    static std::string GetToDeletePath(const std::string &trashDir, const std::string &toDeletePath);
    static int32_t GenerateNewPath(std::string &filePath);
    static int32_t GenerateNewPathOfRecover(std::string &filePath, uint32_t index);
    static int RmDirectory(const std::string &path);
    static std::string GetTrashServerPath(const std::string &userId);
    static int GetFilesInCurrentDir(std::string currentDir, std::vector<std::string> &dirents);
    static int32_t DeleteToTrash(const std::string &userId, const std::string &inUri,
        std::string &trashPath, bool isClient);
private:
    static int CopyAndDeleteFile(const std::string &src, const std::string &dest);
    static int RecurMoveDir(const std::string &srcPath, const std::string &destPath, int mode,
        std::deque<struct ErrFiles> &errfiles);
    static int
        RenameDir(const std::string &src, const std::string &dest, int mode, std::deque<struct ErrFiles> &errfiles);
    static std::string GetTimeSlotFromPath(const std::string &userId, const std::string &path);
    static int RecursiveFunc(const std::string &userId, const std::string &path,
        std::vector<std::string> &dirents);
    static std::string RecurCheckIfOnlyContentInDir(const std::string &path,
        size_t trashWithTimePos, const std::string &trashWithTimePath);
    static std::string FindSourceFilePath(const std::string &userId, const std::string &path,
        const std::string &trashDir);

    static std::string FindSourceFilePath(const std::string &userId, const std::string &path);
    static void ConvertOldFiles(const std::string &userId, std::vector<std::string> &dirents);
    static int32_t DeleteFileToTrash(const DeleteTrashParam &deleteTrashParam, std::string &destPath,
        bool isRetried = false);
    static int32_t DeleteDirToTrash(const DeleteTrashParam &deleteTrashParam, std::string &destPath,
        bool isRetried = false);
    static bool IsSameSrcPathByTrashPath(const std::string &userId, const std::string &trashPath,
        const std::string &srcPath);
};

}
} // OHOS::FileManager
#endif // OHOS_TRASH_UTIL_H