// /*
//  * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
//  */
//
// import { hapTasks } from '@ohos/hvigor-ohos-plugin';
// import { hvigor, getHvigorNode, HvigorPlugin, HvigorNode, HvigorTaskContext } from '@ohos/hvigor';
// import { dtPipelinePackagePlugin } from '@ohos/hypium-plugin';
// import path from 'path';
// import fs from 'fs';
//
// const mModule = getHvigorNode(__filename)
//
// const config = {
//   hvigor: hvigor,
//   packageConfig: {
//     appName: 'HmFileManager', // 与cde架构定义的模块名相同，每个模块流水线归档的hap名，必须配置
//     commandParams: hvigor.getExtraConfig(), // hvigor 命令行参数
//     module: mModule, // 当前模块对象,
//     entryName: '', //一般情况下都配置为空
//     // packageType:'shared'  //配置这个参数时，该模块在hypium-plugin中按照hsp来打包和签名
//     isNotNeedCopySourceCode: 'true' // 配置该参数后，不需要去拷贝模块下的源码到source目录
//   }
// }
//
// const extraConfig = hvigor.getExtraConfig();
// const curTargetName = 'default';
//
// function hapTask(currentNode: HvigorNode, targetName: string): void {
//   const productName = extraConfig.get('product') || 'default';
//   currentNode.registerTask({
//     // 任务名称
//     name: 'modifyPluginTask',
//     // 任务执行体
//     run: (taskContext: HvigorTaskContext) => {
//       const buildFilePath = path.resolve(taskContext.modulePath, `build`);
//       const filePath =
//         path.resolve(buildFilePath, `${productName}/intermediates/res/${curTargetName}/module.json`);
//       if (checkFileExists(filePath)) {
//         const moduleJson = JSON.parse(fs.readFileSync(filePath));
//         const dependencies = moduleJson.module.dependencies;
//         if (dependencies) {
//           moduleJson.module.dependencies = [];
//         }
//         moduleJson.module.dependencies = [{
//           'bundleName': 'com.ohos.security.pickersheet',
//           'moduleName': 'pickersheetlibrary'
//         }];
//         const data = JSON.stringify(moduleJson, null, 2);
//         fs.writeFileSync(filePath, data);
//       }
//     },
//     // 任务前置依赖，先执行default@CompileArkTS，再执行sharePluginTask
//     dependencies: [`${targetName}@CompileArkTS`],
//     // 任务后置依赖，先执行sharePluginTask，再执行default@PackageHsp
//     postDependencies: [`${targetName}@PackageHap`]
//   });
// }
//
// function addModifyShareInfoTask(node: HvigorNode, targetName: string): HvigorPlugin {
//   const packageHapTask = `${targetName}@PackageHap`;
//
//   return {
//     pluginId: 'modifyPickerSheetPlugin',
//     apply(node: HvigorNode): void {
//       // 插件主体
//       if (!node.getTaskByName(packageHapTask)) {
//         return;
//       }
//       hapTask(node, targetName);
//     }
//   };
// }
//
// function checkFileExists(filePath: string): boolean {
//   try {
//     fs.accessSync(filePath, fs.constants.F_OK);
//     return true;
//   } catch (err) {
//     return false;
//   }
// }
//
// export default {
//   system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
//   plugins: [
//     addModifyShareInfoTask(mModule, 'default'),
//     dtPipelinePackagePlugin(config)
//   ]
// }
module.exports = require('@ohos/hvigor-ohos-plugin').hapTasks;