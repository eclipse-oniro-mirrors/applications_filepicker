// /*
//  * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
//  */
//
// // 系统插件
// import { appTasks } from '@ohos/hvigor-ohos-plugin';
// import { hvigor, getHvigorNode } from '@ohos/hvigor';
// import { uploadTestCases } from '@ohos/hypium-plugin';
// // 1. 导入在线签名插件
// import { onlineSignPlugin } from '@ohos/hvigor-ohos-online-sign-plugin';
// import type { OnlineSignOptions } from '@ohos/hvigor-ohos-online-sign-plugin';
//
// // 2. 配置签名参数
// const signOptions: OnlineSignOptions = {
//   profile: 'sign/hapReleaseSignFile/release_phone.p7b', // 签名材料
//   keyAlias: 'HmFileManager',
//   hapSignToolFile: `${process.env.HAP_SIGN_TOOL ??
//     'sign/hap-sign-tool.jar'}`, // 签名工具hap-sign-tool.jar的路径
//   username: `${process.env.ONLINE_USERNAME ?? process.env.W3_ACCOUNT}`, // 环境变量中需要配置用户名和密码
//   password: `${process.env.ONLINE_PASSWD ?? process.env.W3_PASSWORD}`,
//   enableOnlineSign: true                  // 是否启用在线签名
// }
//
// // 配置需要进行签名 + 测试的模块
// const config = {
//   hvigor: hvigor,
//   hvigorNode: getHvigorNode(__filename),
//   templateEngName: 'OH_XTS_HmFileManager_Phone_Test', // CDE架构模板中维护的测试模板英文名称
//   // 此处的ModuleName与各个模块的模块名相匹配
//   // appName与各模块下的hvigorfile.ts中的appName相匹配
//   modulesConfig: [
//     {
//       moduleName: 'phone',
//       appName: 'HmFileManager'
//     }
//   ]
// }
//
// uploadTestCases(config); // 执行上述配置的模块测试，并上传对应的用例信息。 注意：本地调试时该方法务必注释掉，不然会影响流水线文本用例
//
// // hvigorfile 导出范式
// export default {
//   system: appTasks,
//   plugins: [
//   // 3. 应用插件
//     onlineSignPlugin(signOptions),
//   ]
// }
module.exports = require('@ohos/hvigor-ohos-plugin').appTasks;