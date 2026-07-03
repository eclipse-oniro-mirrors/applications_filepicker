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
isPublish=$2
harVersion=$3
products=$4

# 初始化相关路径
APP_HOME="`pwd -P`"
PROJECT_PATH="`pwd -P`"  # 工程目录
TOOLS_INSTALL_ROOT_DIR="$PROJECT_PATH/oh-command-line-tools"
TOOLS_INSTALL_DIR="$TOOLS_INSTALL_ROOT_DIR/ohpm"

if [ ! -d $TOOLS_INSTALL_ROOT_DIR ]; then
  mkdir $TOOLS_INSTALL_ROOT_DIR
fi

if [ ! -d $TOOLS_INSTALL_DIR ]; then
  mkdir $TOOLS_INSTALL_DIR
fi

# 安装ohpm, 若镜像中已存在ohpm，则无需重新安装
function init_ohpm
{
}

# 进入package目录安装依赖
function ohpm_install
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
    ohpm_install "$APP_HOME/features/filePicker"
    ohpm_install "$APP_HOME/features/fileTag"
    ohpm_install "$APP_HOME/features/fileView"
    ohpm_install "$APP_HOME/features/multiInput"
    ohpm_install "$APP_HOME/features/rightMenu"
    ohpm_install "$APP_HOME/features/settings"
    ohpm_install "$APP_HOME/features/sideBar"
    ohpm_install "$APP_HOME/features/titleBar"
    ohpm_install "$APP_HOME/features/toolBar"
    ohpm_install "$APP_HOME/products/pc"
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

    if [ $products = "pc" ];then
      echo "----------------- clean --------------------"
      ./hvigorw -p product=pc clean --parallel --no-daemon

      echo "----------------- build hap (main: entry module)--------------------"
      ./hvigorw --mode module -p module=pc@default -p debuggable=false assembleHap --parallel --incremental --no-daemon --stacktrace -p ohos-test-coverage=true -p testing=true

      echo "----------------- build test hap (ohosTest)--------------------"
      ./hvigorw --mode module -p module=pc@ohosTest -p debuggable=false -p testing=true -p ohos-test-coverage=true assembleHap packageTesting  --parallel --incremental --no-daemon --stacktrace
    else
      echo "----------------- clean --------------------"
      ./hvigorw -p product=phone clean --parallel --no-daemon

      echo "----------------- build hap (main: entry module)--------------------"
      ./hvigorw --mode module -p module=phone@default -p debuggable=false assembleHap --parallel --incremental --no-daemon --stacktrace -p ohos-test-coverage=true -p testing=true

      echo "----------------- build test hap (ohosTest)--------------------"
      ./hvigorw --mode module -p module=phone@ohosTest -p debuggable=false -p testing=true -p ohos-test-coverage=true assembleHap packageTesting  --parallel --incremental --no-daemon --stacktrace
    fi

    echo "-----------------handle DTPipeline.zip--------------------"
    hasPackageDTPipeline=0
    if [ -e "build/DTPipeline.zip" ];then
      file_size=$(stat -c%s "build/DTPipeline.zip")
      if [ $file_size -gt 0 ]; then
        echo "DTPipeline.zip is normal"
      else
        hasPackageDTPipeline=1
        rm -rf build/DTPipeline.zip
        echo "DTPipeline.zip size is 0"
      fi
    else
      hasPackageDTPipeline=1
      echo "build/DTPipeline.zip is not exist"
    fi
    if [ $hasPackageDTPipeline -eq 1 ];then
      pushd build/outputs
      if [ $? -ne 0 ];then
             echo "build/outputs is not exist"
             exit 1
      fi
      zip -r ../DTPipeline.zip ./*
      popd
    fi

    echo "----------------- build hap (main: entry module)--------------------"
    if [ $products = "pc" ];then
      ./hvigorw --mode module -p module=pc -p product=pc -p debuggable=false assembleHap --parallel --incremental --no-daemon --stacktrace
    else
      ./hvigorw --mode module -p module=phone -p product=phone -p debuggable=false assembleHap --parallel --incremental --no-daemon --stacktrace
    fi
}

function publish() {
    echo "gradlew received harVersion : ${harVersion}."
    chmod +x modifyCoordinates.sh
    ./modifyCoordinates.sh ${harVersion}
    if [ $module_name = "common" ];then
      pushd common
    elif [ $module_name = "customdialog" ];then
      pushd features/customDialog
    else
      pushd features/rightMenu
    fi
    echo "start publish module : ${module_name}..."
    npm publish
    echo "publish module : ${module_name} done..."
}

function main {
  if [ $module_name != "clean" ];then
    local startTime=$(date '+%s')

    init_ohpm
    build

    local endTime=$(date '+%s')
    local elapsedTime=$(expr $endTime - $startTime)
    echo "build success in ${elapsedTime}s..."

    if [  $isPublish = "upload_har" ];then
      publish
    fi
  fi
}

main