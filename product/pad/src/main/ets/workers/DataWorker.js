/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import { LogInfo, LogDebug } from '../../../../../../common/LogUtils'
import worker from '@ohos.worker'
import filemanager from '@ohos.filemanager'

var TAG = 'DataWorker'
const parentPort = worker.parentPort
parentPort.onmessage = function (e) {
    LogInfo(TAG, 'DataWorker onMessage')
    let data = e.data
    LogInfo(TAG, 'DataWorker onMessage ' + data.request_data)
    if (data.request_data == 'getRoot') {
        getRootData(data)
    } else if (data.request_data == 'listFile') {
        getListFileData(data)
    } else if (data.request_data == 'createFile') {
        createFile(data);
    }
}

parentPort.onmessageerror = function () {
    LogInfo(TAG, 'onmessageerror')
}

parentPort.onerror = function (data) {
    LogInfo(TAG, 'onerror')
}

function getRootData(data) {
    filemanager.getRoot()
        .then(file => {
            handleData(file, data)
        })
        .catch((error) => {
            LogDebug(TAG, 'getRoot error' + error)
        });
}

function getListFileData(data) {
    if (data.offset == undefined || data.count == undefined) {
        LogDebug(TAG, 'path = ' + data.path + " type = " + data.media_type)
        filemanager.listFile(data.path, data.media_type)
            .then(file => {
                handleData(file, data)
            })
            .catch((error) => {
                LogDebug(TAG, 'getListFileData error' + error)
                handleData([], data)
            })
    } else {
        LogDebug(TAG, 'path = ' + data.path + " type = " + data.media_type + " offset = " + data.offset)
        filemanager.listFile(data.path, data.media_type, {
            'offset': data.offset,
            'count': data.count
        })
            .then(file => {
                handleData(file, data)
            })
            .catch((error) => {
                LogDebug(TAG, 'getListFileData offset error' + error)
                handleData([], data)
            })
    }
}

function createFile(data) {
    LogDebug(TAG, 'path = ' + data.path + ' files = ' + data.save_name)
    filemanager.createFile(data.path, data.save_name)
        .then((uri) => {
            handleData(uri, data)
        })
        .catch((error) => {
            LogDebug(TAG, 'createFile error' + error)
        })
}

function handleData(file, data) {
    LogInfo(TAG, 'handleData')
    var info = JSON.stringify(file)
    LogInfo(TAG, 'info = ' + info.length)
    var buf = new ArrayBuffer(info.length * 2)
    var bufView = new Uint16Array(buf)
    for (var index = 0; index < info.length; index++) {
        bufView[index] = info.charCodeAt(index)
    }
    parentPort.postMessage({ data: bufView, params: data })
}

