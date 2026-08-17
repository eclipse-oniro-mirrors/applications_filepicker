#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2024 - 2024. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
#传入版本号
version=$1
echo "modifyCoordinates received harVersion : ${version}."

search_common="@ohos/common" # 设置要查找的字符串
replace_common="@hw-pc-filemanager/common" # 设置要替换成的字符串
customdialog_directory="./features/customDialog/src/main/ets" # 设置要遍历的目录路径

rightmenu_search_customdialog="@ohos/customDialog" # 设置要查找的字符串
rightmenu_replace_customdialog="@hw-pc-filemanager/customDialog" # 设置要替换成的字符串
rightmenu_directory="./features/rightMenu/src/main/ets" # 遍历rightMenu的目录路径

#替换customDialog包中的common引用
find "$customdialog_directory" -type f | while read file; do
    sed -i "s!$search_common!$replace_common!g" "$file"
    echo "$file"
done

#替换rightMenu包中的common引用
find "$rightmenu_directory" -type f | while read file; do
    sed -i "s!$search_common!$replace_common!g" "$file"
    echo "$file"
done

#替换rightMenu包中的common引用
find "$rightmenu_directory" -type f | while read file; do
    sed -i "s!$rightmenu_search_customdialog!$rightmenu_replace_customdialog!g" "$file"
    echo "$file"
done

path_common_oh_package_json5="./common/oh-package.json5"  # common模块oh-package.json5
common_old_name='"name": "common"' # common模块旧名称
common_new_name='"name": "@hw-pc-filemanager/common"' # common模块新名称
common_old_version='"version": "1.0.0"' # common模块旧版本号
common_new_version='"version": "'$version'"' # common模块新版本号
common_old_metadata='  }'
common_new_metadata='  },"metadata":{"workers":["./src/main/ets/workers/FileOperateWorker.ets"]}'

#替换common oh-package.json5
sed -i "s!$common_old_name!$common_new_name!g" $path_common_oh_package_json5
sed -i "s!$common_old_version!$common_new_version!g" $path_common_oh_package_json5
sed -i "s@$common_old_metadata@$common_new_metadata@g" $path_common_oh_package_json5

path_customdialog_oh_package_json5="./features/customDialog/oh-package.json5"  # customDialog模块oh-package.json5
customdialog_old_name='"name": "customDialog"' # customDialog模块旧名称
customdialog_new_name='"name": "@hw-pc-filemanager/customDialog"' # customDialog模块新名称
customdialog_old_version='"version": "1.0.0"' # customDialog模块旧版本号
customdialog_new_version='"version": "'$version'"' # customDialog模块新版本号
common_old_dependencies='"@ohos/common": "../../common"' # customDialog模块旧依赖
common_new_dependencies='"@hw-pc-filemanager/common": "'$version'"' # customDialog模块新依赖
common_old_publishconfig='  }'
common_new_publishconfig='  }'

#替换customDialog oh-package.json5
sed -i "s!$customdialog_old_name!$customdialog_new_name!g" $path_customdialog_oh_package_json5
sed -i "s!$customdialog_old_version!$customdialog_new_version!g" $path_customdialog_oh_package_json5
sed -i "s!$common_old_dependencies!$common_new_dependencies!g" $path_customdialog_oh_package_json5
sed -i "s!$common_old_publishconfig!$common_new_publishconfig!g" $path_customdialog_oh_package_json5


path_rightmenu_oh_package_json5="./features/rightMenu/oh-package.json5"  # rightMenu模块oh-package.json5
rightmenu_old_name='"name": "rightMenu"' # rightMenu模块旧名称
rightmenu_new_name='"name": "@hw-pc-filemanager/rightMenu"' # rightMenu模块新名称
rightmenu_old_version='"version": "1.0.0"' # rightMenu模块旧版本号
rightmenu_new_version='"version": "'$version'"' # rightMenu模块新版本号
customdialog_old_dependencies='"@ohos/customDialog": "../customDialog"' # rightMenu模块旧依赖
customdialog_new_dependencies='"@hw-pc-filemanager/customDialog": "'$version'"' # rightMenu模块新依赖

#替换rightMenu oh-package.json5
sed -i "s!$rightmenu_old_name!$rightmenu_new_name!g" $path_rightmenu_oh_package_json5
sed -i "s!$rightmenu_old_version!$rightmenu_new_version!g" $path_rightmenu_oh_package_json5
sed -i "s!$common_old_dependencies!$common_new_dependencies!g" $path_rightmenu_oh_package_json5
sed -i "s!$customdialog_old_dependencies!$customdialog_new_dependencies!g" $path_rightmenu_oh_package_json5
sed -i "s!$common_old_publishconfig!$common_new_publishconfig!g" $path_rightmenu_oh_package_json5

path_common_package_json="./common"
path_customdialog_package_json="./features/customDialog"
path_rightmenu_package_json="./features/rightMenu"
package_json_name="package.json"

#生成package.json
cp "$path_common_oh_package_json5" "$path_common_package_json/$package_json_name"
cp "$path_customdialog_oh_package_json5" "$path_customdialog_package_json/$package_json_name"
cp "$path_rightmenu_oh_package_json5" "$path_rightmenu_package_json/$package_json_name"
echo "modifyCoordinates done."