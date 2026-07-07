/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

// import { systemShare } from '@kit.ShareKit';
import { UiUtil } from '../utils/UiUtil';
import lazy { UTD } from '../../../../indexLazyLoadTs';
import { FileInfo } from '../fileoperate/FileInfo';
import { HiLog } from '../dfx/HiLog';
import { AppDataPathUtil } from '../utils/AppDataPathUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import FileMimeTypeUtil from '../utils/FileMimeTypeUtil';
import { MimeType } from '../model/MimeType';
import { getUtdByExtension } from './ShowShareDialogFun';
import { FileSourceType } from '../const/Constant';
import { JSON } from '@kit.ArkTS';

const TAG = 'SystemShareUtil';
const UNKNOWN_UTD_HEAD = 'flex';

/**
 * 系统分享接口
 */
export class SystemShareUtil {
  // private static shareController: systemShare.ShareController | undefined = undefined;

  /**
   * 显示分享弹窗
   * @param fileList 要分享的文件列表
   * @returns
   */
  // public static async showShareDialog(fileList: FileInfo[]): Promise<void> {
  //   HiLog.info(TAG, 'showShareDialog start, fileList length:' + fileList.length);
  //   // 构造分享数据
  //   let shareData: systemShare.SharedData | undefined = undefined;
  //   let hasSandboxFile: boolean = false;
  //   fileList.forEach((item: FileInfo) => {
  //     let recordUtd: string = SystemShareUtil.getRecordUtd(item);
  //     const record: systemShare.SharedRecord = {
  //       utd: recordUtd,
  //       uri: item.uri,
  //       title: UiUtil.translateFileNameByUri(item.uri, item.fileName, item.isFolder)
  //     };
  //     if (!shareData) {
  //       shareData = new systemShare.SharedData(record);
  //     } else {
  //       shareData.addRecord(record);
  //     }
  //   });
  //   HiLog.debugPrivate(TAG, 'build shareData success, shareData:', JSON.stringify(shareData));
    // 设置分享的配置项，如选择模式和预览模式
    // const sharePreviewMode: systemShare.SharePreviewMode = getPreviewMode(fileList);
    // const shareOptions: CustomShareControllerOptions = {
    //   selectionMode: fileList.length > 1 ? systemShare.SelectionMode.BATCH : systemShare.SelectionMode.SINGLE,
    //   previewMode: sharePreviewMode,
    //   hasSandboxFile: hasSandboxFile
    // };
  //   HiLog.debugPrivate(TAG, 'shareOptions:', JSON.stringify(shareOptions));
  //   if (shareData) {
  //     SystemShareUtil.shareController = new systemShare.ShareController(shareData);
  //     const context =
  //       GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getMainAbilityContext();
  //     await showShareDialogFun(context, SystemShareUtil.shareController, shareOptions);
  //     HiLog.info(TAG, 'shareController show executed');
  //   }
  // }

  /**
   * 获取分享的utd类型
   * @param item 文件信息
   * @returns 通用数据类型
   */
  public static getRecordUtd(item: FileInfo): string {
    HiLog.debug(TAG, 'start to get specific utd');
    if (item.isFolder) {
      return UTD.UniformDataType.FOLDER;
    }
    const fileSuffix: string = FileMimeTypeUtil.getLastSuffix(item.fileName);
    if (fileSuffix === '') {
      return UTD.UniformDataType.FILE;
    }
    try {
      const belongedType: string = SystemShareUtil.getBelongUtdType(item);
      const utdTypes: string[] = getUtdByExtension(`.${fileSuffix}`);
      HiLog.info(TAG, `utdTypes=${JSON.stringify(utdTypes)}`);
      // 唯一的且有匹配的utd类型直接返回
      if (utdTypes.length === 1 && !utdTypes[0].startsWith(UNKNOWN_UTD_HEAD)) {
        return utdTypes[0];
      } else {
        // 后缀对应多个utd类型时，返回和归属类型匹配的utd类型
        for (const utdType of utdTypes) {
          const typeObj: UTD.TypeDescriptor = UTD.getTypeDescriptor(utdType);
          if (typeObj.belongsTo(belongedType)) {
            return utdType;
          }
        }
      }
      return belongedType;
    } catch (err) {
      HiLog.error(TAG, 'failed to get utd by fileExtention');
    }
    return UTD.UniformDataType.FILE;
  }

  /**
   * 获取归属的utd
   * @param item
   * @returns 归属的标准化数据类
   */
  private static getBelongUtdType(item: FileInfo): string {
    let recordUtd: UTD.UniformDataType = UTD.UniformDataType.FILE;
    let itemMimeType: MimeType = FileMimeTypeUtil.getFileMimeType(item.fileName);
    if (item.isFolder) {
      recordUtd = UTD.UniformDataType.FOLDER;
    } else if (FileMimeTypeUtil.isImage(itemMimeType)) {
      recordUtd = UTD.UniformDataType.IMAGE;
    } else if (FileMimeTypeUtil.isVideo(itemMimeType)) {
      recordUtd = UTD.UniformDataType.VIDEO;
    } else if (FileMimeTypeUtil.isAudio(itemMimeType)) {
      recordUtd = UTD.UniformDataType.AUDIO;
    }
    return recordUtd;
  }

  /**
   * 监听系统分享半模态关闭时间
   * @param callback Function
   * @returns void
   */
  // public static onDialogDismissEvent(callback: () => void): void {
  //   try {
  //     HiLog.info(TAG, 'onDialogDismissEvent');
  //     SystemShareUtil.shareController?.on('dismiss', callback);
  //   } catch (e) {
  //     HiLog.error(TAG, `onDialogDismissEvent error, code: ${e?.code}, msg: ${e?.message}`);
  //   }
  // }

  /**
   * 取消监听系统分享半模态关闭时间
   * @returns void
   */
  // public static offDialogDismissEvent(callback: () => void): void {
  //   try {
  //     HiLog.info(TAG, 'offDialogDismissEvent');
  //     SystemShareUtil.shareController?.off('dismiss', callback);
  //   } catch (e) {
  //     HiLog.error(TAG, `offDialogDismissEvent error, code: ${e?.code}, msg: ${e?.message}`);
  //   }
  // }

  /**
   * 监听系统分享事件
   * @param callback Function
   * @returns void
   */
  // public static onShareCompleteEvent(callback: Callback<systemShare.ShareOperationResult>): void {
  //   try {
  //     HiLog.info(TAG, 'onShareCompleteEvent');
  //     SystemShareUtil.shareController?.on('shareCompleted', callback);
  //   } catch (e) {
  //     HiLog.error(TAG, `onShareCompleteEvent error, code: ${e?.code}, msg: ${e?.message}`);
  //   }
  // }

  /**
   * 取消监听系统分享事件
   * @returns void
   */
  // public static offShareCompleteEvent(callback: Callback<systemShare.ShareOperationResult>): void {
  //   try {
  //     HiLog.info(TAG, 'offShareCompleteEvent');
  //     SystemShareUtil.shareController?.off('shareCompleted', callback);
  //   } catch (e) {
  //     HiLog.error(TAG, `offShareCompleteEvent error, code: ${e?.code}, msg: ${e?.message}`);
  //   }
  // }

  // 判断是否是另存为 / 保存至图库操作
  // public static isSaveOperation(operationName: string): boolean {
  //   return operationName === systemShare.ShareAbilityName.SAVE_AS_FILE ||
  //     operationName === systemShare.ShareAbilityName.SAVE_TO_MEDIA_ASSET;
  //   return false;
  // }
}

/**
 * 获取分享弹窗的展示模式，卡片或预览
 * @param fileList 文件信息列表
 * @returns 展示模式
 */
// function getPreviewMode(fileList: FileInfo[]): systemShare.SharePreviewMode {
//   // 选择的文件全部是图片或视频时分享弹窗大图预览形式展示
//   const isAllImageOrVideo = fileList.every((fileInfo: FileInfo) => FileMimeTypeUtil.isImage(fileInfo.mimeTypeObj) ||
//   FileMimeTypeUtil.isVideo(fileInfo.mimeTypeObj));
//   return isAllImageOrVideo ? systemShare.SharePreviewMode.DETAIL : systemShare.SharePreviewMode.DEFAULT;
// }

// interface CustomShareControllerOptions extends systemShare.ShareControllerOptions {
//   hasSandboxFile: boolean
// }