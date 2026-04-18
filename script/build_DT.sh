#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2023 - 2023. All rights reserved.
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
export handle_dtpipeline

# 处理DT安装包
function handle_dtpipeline()
{
    echo "-----------------handle DTPipeline.zip--------------------"
        has_package_dtpipeline=0
        if [ -e "build/DTPipeline.zip" ];then
          file_size=$(stat -c%s "build/DTPipeline.zip")
          if [ $file_size -gt 0 ]; then
            echo "DTPipeline.zip is normal"
          else
            has_package_dtpipeline=1
            rm -rf build/DTPipeline.zip
            echo "DTPipeline.zip size is 0"
          fi
        else
          has_package_dtpipeline=1
          echo "build/DTPipeline.zip is not exist"
        fi
        if [ $has_package_dtpipeline -eq 1 ];then
          pushd build/outputs
          if [ $? -ne 0 ];then
                 echo "build/outputs is not exist"
                 exit 1
          fi
          zip -r ../DTPipeline.zip ./*
          popd
        fi
}