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

const path = require('path');
const childProcess = require('child_process');

const projectRootPath = process.cwd();
const userName = process.env.HW_SIGN_USER_NAME || process.env.ONLINESIGN_USERNAME;
const password = '';
const onlineSignServer = '';
const hapSignTool = 'hap-sign-tool.jar';
const hapSignOnlinePlugin = 'hapsign-online-plugin.jar';
const p7bFileNamePhone = 'hapDebugSignFile/debug_phone.p7b';
const p7bFileNamePc = 'hapReleaseSignFile/release_pc.p7b';
const keyAlias = 'HOS Application Provision Debug V2';
const onlineSignJarPath = process.env.onlineSignJarPath || path.resolve(projectRootPath, 'sign');
const signMaterialPath = path.resolve(projectRootPath, 'sign');

// 这个是sign.js的副本，主要是为了使用调试签名打包，方便验证应用市场镜像环境的APP包的覆盖安装是否正常
// Tips: 在IDE场景下,在线签名工具生成的签名后的hap必须默认仍然放置到/build/{product}/outputs/default/目录下,且包名以signed.hap为后缀
// executeOnlineSign函数的四个参数不可变动。不能增加或者减少，否则会影响后续切BAC自动化打包流水线
function executeOnlineSign(inputFile, outputFile, assembleName = '', envType = '', product = '') {

    const signToolFile = path.resolve(onlineSignJarPath, hapSignTool);

    let command2 = [];
    let p7bFileName = p7bFileNamePc;
    if (product === 'phone') {
        p7bFileName = p7bFileNamePhone;
        if (assembleName === 'assembleApp' && envType) {
            p7bFileName = `${envType}AgcSignFile/HmFileManagerRelease.p7b`;
            command2 = [
                '-appCertFile',
                path.resolve(signMaterialPath, `${envType}AgcSignFile/HmFileManager.cer`)
            ];
        }
    }

    let p7bFile = path.resolve(signMaterialPath, p7bFileName);
    console.info(p7bFile);
    const command1 = [
        '-jar',
        signToolFile,
        'sign-app',
        '-mode',
        'remoteSign',
        '-signServer',
        onlineSignServer,
        '-signerPlugin',
        hapSignOnlinePlugin,
        '-onlineAuthMode',
        'account',
        '-username',
        userName,
        '-userPwd',
        password,
        '-profileFile',
        p7bFile
    ];

    const command3 = [
        '-compatibleVersion',
        '8',
        '-signAlg',
        'SHA256withECDSA',
        '-keyAlias',
        keyAlias,
        '-inFile',
        inputFile,
        '-outFile',
        outputFile
    ];

    const command = [
        ...command1,
        ...command2,
        ...command3
    ];

    const result = childProcess.spawnSync('java', command, {
        encoding: 'utf-8',
        windowsHide: true
    });
    if (result.stderr) {
        console.error(result.stderr.trim());
    }
}

module.exports = {
    executeOnlineSign: executeOnlineSign
};