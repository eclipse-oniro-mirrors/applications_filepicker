#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2023 - 2023. All rights reserved.
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
set -ex

export DEVECO_SDK_HOME=${HOS_SDK_HOME}
echo "DEVECO_SDK_HOME is ${DEVECO_SDK_HOME}"

echo "old NODE_HOME is ${NODE_HOME}"

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
echo "OHOS_BASE_SDK_HOME is ${OHOS_BASE_SDK_HOME}"
node -v
npm -v
npm config list
npm config set strict-ssl false

#接收参数
module_name=$1
is_publish=$2
har_version=$3
products=$4

# 初始化相关路径
APP_HOME=$(pwd -P)
PROJECT_PATH=$(pwd -P)  # 工程目录

# 进入package目录安装依赖
function ohpm_install()
{
    cd $1
    ohpm -v
    ohpm install
}

# 环境适配
function build() {
    # 根据业务情况适配local.properties
    cd ${APP_HOME}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "$APP_HOME"
    ohpm_install "$APP_HOME/common"
    ohpm_install "$APP_HOME/features/addressBar"
    ohpm_install "$APP_HOME/features/bottomBar"
    ohpm_install "$APP_HOME/features/customDialog"
    ohpm_install "$APP_HOME/features/fileView"
    ohpm_install "$APP_HOME/features/sideBar"
    ohpm_install "$APP_HOME/features/titleBar"
    ohpm_install "$APP_HOME/products/phone"

    # 如果构建过程报错 ERR_PNPM_OUTDATED_LOCKFILE，需要增加配置：lockfile=false
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc

    # 获得签名jar文件
    cd $PROJECT_PATH/sign
    chmod +x build.sh
    ./build.sh

    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${APP_HOME}
    chmod +x hvigorw

    # 构建hap包
    build_hap
}

function build_hap() {
    # 编包
    echo "----------------- clean --------------------"
    hvigorw -p product=phone clean --parallel --no-daemon
    echo "----------------- build hap (main: entry module)--------------------"
    hvigorw --mode module -p module=phone -p product=phone -p debuggable=false assembleHap --parallel --incremental --no-daemon --stacktrace
    # 重命名hap包
    cd $PROJECT_PATH/products/phone/build/phone/outputs/default
    mv phone-default-signed.hap HmFileManager.hap
    # 构建公示文件
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > publicity.xml
    echo "<packageInfo package=\"com.ohos.filemanager\" feature=\"文件管理是一个高效管理本地和云盘文件的管理器。通过文件管理器用户可以在本地、云盘中浏览、复制、删除、重命名等\" author=\"xxx\"></packageInfo>" >> publicity.xml
}

function main() {
  if [ "${module_name}" != "clean" ];then
    local start_time=$(date '+%s')

    build

    local end_time=$(date '+%s')
    local elapsed_time=$(expr $end_time - $start_time)
    echo "build success in ${elapsed_time}s..."
  fi
}

main