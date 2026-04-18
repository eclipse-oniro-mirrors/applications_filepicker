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

import { FileInfo, HiLog, toast } from "@ohos/common";
import { common, InsightIntentFunctionMethod } from "@kit.AbilityKit";
import { systemSoundManager } from "@kit.AudioKit";
import fs from '@ohos.file.fs'

const TAG: string = 'RingtoneTypeMenu';

interface RingtoneType {
  icon: string | ResourceStr
  text: string
  more: boolean
  onclick: () => void
}

/** 铃音属性项（与 getRingtoneAttrList / getSystemToneAttrList 等返回项结构兼容），用于 try-catch 后安全遍历 */
interface ToneAttrItem {
  getUri?: () => string;
  getTitle?: () => string;
}

@Component
export struct RingtoneTypeMenu {
  private fileInfo: FileInfo | null = null;
  private onClose: () => void = () => {
  };
  private ringtoneTypeList: RingtoneType[] = [
    {
      icon: $r('sys.symbol.phone'),
      text: '设为来电铃声',
      more: true,
      onclick: () => {
      },
    },
    {
      icon: $r('sys.symbol.message'),
      text: '设为信息铃声',
      more: true,
      onclick: () => {
      },
    },
    {
      icon: $r('sys.symbol.envelope'),
      text: '设为通知铃声',
      more: false,
      onclick: () => {
        if (this.fileInfo) {
          this.setMsgNotifTone(this.fileInfo, 3)
        }
      }
    },
    {
      icon: $r('sys.symbol.alarm'),
      text: '设为闹钟铃声',
      more: false,
      onclick: () => {
        if (this.fileInfo) {
          this.setAlarmTone(this.fileInfo)
        }
      }
    },
    {
      icon: $r('sys.symbol.bell'),
      text: '我的铃声',
      more: true,
      onclick: () => {
        this.jumpToMyRingtones()
      }
    },
  ]

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.onClose()
        })

      // 菜单内容区域
      // 标题
      Column() {
        Row() {
          Text('设为铃声')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)

          Blank()

          Row() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(24)
              .aspectRatio(1)
          }
          .width(40)
          .aspectRatio(1)
          .borderRadius(20)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.onClose()
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 })

        ForEach(this.ringtoneTypeList, (item: RingtoneType, index: number) => {
          // 为"设为来电铃声"单独处理
          if (item.text === '设为来电铃声') {
            Row({ space: 16 }) {
              SymbolGlyph(item.icon as Resource)
                .fontSize(24);

              Row() {
                Text(item.text);

                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(24)
                  .visibility(item.more ? Visibility.Visible : Visibility.None)
                  .fontColor([$r('sys.color.icon_fourth')])
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.SpaceBetween)
              .border({
                color: { bottom: 'rgba(0, 0, 0, 0.05)' },
                width: { bottom: index === this.ringtoneTypeList.length - 1 ? 0 : 1 }
              })
              .padding({ top: 10, bottom: 10 });
            }
            .padding({ top: 10, bottom: 10 })
            .onClick(() => item.onclick())
            .bindMenu(this.CallRingtoneMenu, { placement: Placement.Right });
          } // 为"设为信息铃声"单独处理
          else if (item.text === '设为信息铃声') {
            Row({ space: 16 }) {
              SymbolGlyph(item.icon as Resource)
                .fontSize(24);

              Row() {
                Text(item.text);

                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(24)
                  .visibility(item.more ? Visibility.Visible : Visibility.None)
                  .fontColor([$r('sys.color.ohos_id_color_fourth')])
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.SpaceBetween)
              .border({
                color: { bottom: 'rgba(0, 0, 0, 0.05)' },
                width: { bottom: index === this.ringtoneTypeList.length - 1 ? 0 : 1 }
              })
              .padding({ top: 10, bottom: 10 });
            }
            .padding({ top: 10, bottom: 10 })
            .onClick(() => item.onclick())
            .bindMenu(this.MessageRingtoneMenu, { placement: Placement.Right });
          } else {
            Row({ space: 16 }) {
              SymbolGlyph(item.icon as Resource)
                .fontSize(24)

              Row() {
                Text(item.text)

                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(24)
                  .visibility(item.more ? Visibility.Visible : Visibility.None)
                  .fontColor([$r('sys.color.icon_fourth')])
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.SpaceBetween)
              .border({
                color: { bottom: 'rgba(0, 0, 0, 0.05)' },
                width: { bottom: index === this.ringtoneTypeList.length - 1 ? 0 : 1 }
              })
              .padding({ top: 10, bottom: 10 })
            }
            .padding({
              top: 10,
              bottom: 10
            })
            .onClick(() => {
              item.onclick()
            })
          }
        })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 32
      })
      .borderRadius({
        topLeft: 24,
        topRight: 24
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }

  // 来电铃声菜单
  @Builder
  CallRingtoneMenu() {
    Menu() {
      MenuItem({ content: '卡1' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setRingtone(this.fileInfo, 0);
            this.onClose();
          }
        });
      MenuItem({ content: '卡2' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setRingtone(this.fileInfo, 1);
            this.onClose();
          }
        });
      MenuItem({ content: '同时设定' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setRingtone(this.fileInfo, 2);
            this.onClose();
          }
        });
    }
  }

  // 信息铃声菜单
  @Builder
  MessageRingtoneMenu() {
    Menu() {
      MenuItem({ content: '卡1' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setMsgNotifTone(this.fileInfo, 0);
            this.onClose();
          }
        });
      MenuItem({ content: '卡2' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setMsgNotifTone(this.fileInfo, 1);
            this.onClose();
          }
        });
      MenuItem({ content: '同时设定' })
        .onClick(async () => {
          // 后续实现具体操作
          if (this.fileInfo) {
            await this.setMsgNotifTone(this.fileInfo, 2);
            this.onClose();
          }
        });
    }
  }

  private jumpToMyRingtones() {
    let context: common.UIAbilityContext = getContext() as common.UIAbilityContext
    let want: Want = {
      bundleName: 'com.ohos.settings',
      abilityName: 'com.ohos.settings.MainAbility',
      uri: 'volume_settings', // NavEntryKey.WIFI_ENTRY
    }
    context?.startAbility(want);
    // 关闭半模态
    this.onClose()
  }

  //  来电铃声相关辅助方法

  /**
   * 清理来电铃音库：删除「不在保留列表」中的自定义铃音，避免铃音库堆积。
   * 按 listType 获取该类型下的铃音列表，遍历每条铃音；若其 uri 不在 keepUris 中则从系统铃音库移除。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例（SystemSoundManager）
   * @param listType - 铃音类型（卡1/卡2 等 RingtoneType），决定从哪类铃音库取列表
   * @param keepUris - 需要保留的铃音 URI 列表（一般为当前卡1、卡2正在使用的铃声 URI），这些不会被删除
   */
  private async cleanupRingtoneLibrary(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    listType: systemSoundManager.RingtoneType,
    keepUris: string[]
  ): Promise<void> {
    let list: ToneAttrItem[] = [];
    try {
      const raw = await mgr.getRingtoneAttrList(context, listType);
      list = (raw != null && Array.isArray(raw)) ? raw : [];
    } catch (e) {
      HiLog.info(TAG, `getRingtoneAttrList failed or ringtone library empty: ${JSON.stringify(e)}`);
    }
    HiLog.info(TAG, `getRingtoneAttrList. length=${list.length}`);
    for (let i = 0; i < list.length; i++) {
      try {
        const uri = list[i].getUri?.();
        if (uri && keepUris.indexOf(uri) < 0) {
          try {
            await mgr.removeCustomizedTone(context, uri);
            HiLog.info(TAG, `Succeeded in removing other tone: ${uri}`);
          } catch (err) {
            HiLog.error(TAG,
              `Failed to removeCustomizedTone. Code: ${(err as BusinessError).code}, message: ${(err as BusinessError).message}`);
          }
        }
      } catch (error) {
        HiLog.error(TAG, `Error getting ToneAttr ${i} properties: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 在来电铃音库中按「文件名」查找已存在的铃音 URI。
   * 根据 listType 获取铃音列表，遍历每条铃音，若 title 与 fileName 相同则返回其 uri；未找到返回 null。
   * 用于设置铃声时复用已有铃音，避免重复添加同名文件。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param listType - 铃音类型（卡1/卡2）
   * @param fileName - 要匹配的文件名（与铃音 title 对比）
   * @returns 匹配到的铃音 URI，未找到则返回 null
   */
  private async findRingtoneUriByFileName(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    listType: systemSoundManager.RingtoneType,
    fileName: string
  ): Promise<string | null> {
    let list: ToneAttrItem[] = [];
    try {
      const raw = await mgr.getRingtoneAttrList(context, listType);
      list = (raw != null && Array.isArray(raw)) ? raw : [];
    } catch (e) {
      HiLog.info(TAG, `getRingtoneAttrList failed or ringtone library empty: ${JSON.stringify(e)}`);
    }
    for (let i = 0; i < list.length; i++) {
      try {
        const uri = list[i].getUri?.();
        const title = list[i].getTitle?.();
        if (uri && title === fileName) {
          return uri;
        }
      } catch (error) {
        HiLog.error(TAG, `Error getting ToneAttr ${i} properties: ${JSON.stringify(error)}`);
      }
    }
    return null;
  }

  /**
   * 为「单张 SIM 卡」设置来电铃声。
   * 若当前该卡铃声文件名已是 fileInfo.fileName 则仅 toast 并返回；否则在铃音库中按文件名查找，
   * 若找到则直接 setRingtoneUri 复用，若未找到则用 fd 将文件加入铃音库再 setRingtoneUri。最后按需 toast。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param fileInfo - 当前选中的音频文件信息（含 uri、fileName）
   * @param fd - 已打开的音频文件描述符，用于 addCustomizedTone 时读取文件内容
   * @param typeSim - 要设置的 SIM 类型（卡1 或 卡2，RingtoneType）
   * @param currentFileName - 该卡当前铃声的文件名（从当前铃声 URI 解析），用于判断是否已是同一文件
   * @param toastMsg - 设置成功后要弹出的提示文案；若为空字符串则不 toast（用于「同时设定」时避免重复提示）
   */
  private async setRingtoneForOneSim(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    fileInfo: FileInfo,
    fd: number,
    typeSim: systemSoundManager.RingtoneType,
    currentFileName: string | undefined,
    toastMsg: string
  ): Promise<void> {
    if (currentFileName === fileInfo.fileName) {
      HiLog.info(TAG, `Ringtone already set to ${fileInfo.fileName}`);
      if (toastMsg) {
        toast(toastMsg);
      }
      return;
    }
    const targetUri = await this.findRingtoneUriByFileName(context, mgr, typeSim, fileInfo.fileName);
    if (targetUri) {
      HiLog.info(TAG, `Ringtone already exists in library: ${targetUri}`);
      await mgr.setRingtoneUri(context, targetUri, typeSim);
      HiLog.info(TAG, 'Succeeded in doing setRingtoneUri with existing tone');
    } else {
      const toneAttrs = systemSoundManager.createCustomizedToneAttrs();
      toneAttrs.setTitle(fileInfo.fileName);
      toneAttrs.setFileName(fileInfo.fileName);
      toneAttrs.setCategory(systemSoundManager.TONE_CATEGORY_RINGTONE);
      const newUri = await mgr.addCustomizedTone(context, toneAttrs, fd, 0);
      HiLog.info(TAG, `Succeeded in doing addCustomizedTone. value=${newUri}`);
      await mgr.setRingtoneUri(context, newUri, typeSim);
      HiLog.info(TAG, 'Succeeded in doing setRingtoneUri');
    }
    if (toastMsg) {
      toast(toastMsg);
    }
  }

  //  闹钟铃声相关辅助方法

  /**
   * 清理闹钟铃音库：删除除「当前正在使用的闹钟铃音」以外的所有自定义闹钟铃音。
   * 获取闹钟铃音列表，遍历每条；若 uri 与 keepUri 不同（或 keepUri 为空则删除所有）则从系统移除。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param keepUri - 当前正在使用的闹钟铃音 URI，仅保留此项；若为空字符串则删除库中全部自定义闹钟铃音
   */
  private async cleanupAlarmToneLibrary(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    keepUri: string
  ): Promise<void> {
    let list: ToneAttrItem[] = [];
    try {
      const raw = await mgr.getAlarmToneAttrList(context);
      list = (raw != null && Array.isArray(raw)) ? raw : [];
    } catch (e) {
      HiLog.info(TAG, `getAlarmToneAttrList failed or alarm tone library empty: ${JSON.stringify(e)}`);
    }
    HiLog.info(TAG, `getAlarmToneAttrList. length=${list.length}`);
    for (let i = 0; i < list.length; i++) {
      try {
        const uri = list[i].getUri?.();
        if (uri && (keepUri === '' || uri !== keepUri)) {
          try {
            await mgr.removeCustomizedTone(context, uri);
            HiLog.info(TAG, `Succeeded in removing other AlarmTone: ${uri}`);
          } catch (err) {
            HiLog.error(TAG,
              `Failed to removeCustomizedTone. Code: ${(err as BusinessError).code}, message: ${(err as BusinessError).message}`);
          }
        }
      } catch (error) {
        HiLog.error(TAG, `Error getting ToneAttr ${i} properties: ${JSON.stringify(error)}`);
      }
    }
  }

  // 系统铃音（短信/通知）相关辅助方法

  /**
   * 清理系统铃音库（短信或通知）：删除「不在保留列表」中的自定义系统铃音。
   * 按 listType 获取该类型的系统铃音列表，遍历每条；若 uri 不在 keepUris 中则从系统移除。
   * 保留的一般为当前卡1、卡2 短信铃声及系统通知铃声的 URI，避免误删正在使用的铃音。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param listType - 系统铃音类型（卡1 短信 / 卡2 短信 / 系统通知，SystemToneType）
   * @param keepUris - 需要保留的铃音 URI 列表
   */
  private async cleanupSystemToneLibrary(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    listType: systemSoundManager.SystemToneType,
    keepUris: string[]
  ): Promise<void> {
    let list: ToneAttrItem[] = [];
    try {
      const raw = await mgr.getSystemToneAttrList(context, listType);
      list = (raw != null && Array.isArray(raw)) ? raw : [];
    } catch (e) {
      HiLog.info(TAG, `getSystemToneAttrList failed or system tone library empty: ${JSON.stringify(e)}`);
    }
    HiLog.info(TAG, `getSystemToneAttrList. length=${list.length}`);
    for (let i = 0; i < list.length; i++) {
      try {
        const uri = list[i].getUri?.();
        if (uri && keepUris.indexOf(uri) < 0) {
          try {
            await mgr.removeCustomizedTone(context, uri);
            HiLog.info(TAG, `Succeeded in removing other tone: ${uri}`);
          } catch (err) {
            HiLog.error(TAG,
              `Failed to removeCustomizedTone. Code: ${(err as BusinessError).code}, message: ${(err as BusinessError).message}`);
          }
        }
      } catch (error) {
        HiLog.error(TAG, `Error getting ToneAttr ${i} properties: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 在系统铃音库（短信/通知）中按「文件名」查找已存在的铃音 URI。
   * 根据 listType 获取系统铃音列表，遍历每条，若 title 与 fileName 相同则返回其 uri；未找到返回 null。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param listType - 系统铃音类型（卡1/卡2 短信 或 系统通知）
   * @param fileName - 要匹配的文件名
   * @returns 匹配到的铃音 URI，未找到则返回 null
   */
  private async findSystemToneUriByFileName(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    listType: systemSoundManager.SystemToneType,
    fileName: string
  ): Promise<string | null> {
    let list: ToneAttrItem[] = [];
    try {
      const raw = await mgr.getSystemToneAttrList(context, listType);
      list = (raw != null && Array.isArray(raw)) ? raw : [];
    } catch (e) {
      HiLog.info(TAG, `getSystemToneAttrList failed or system tone library empty: ${JSON.stringify(e)}`);
    }
    for (let i = 0; i < list.length; i++) {
      try {
        const uri = list[i].getUri?.();
        const title = list[i].getTitle?.();
        if (uri && title === fileName) {
          return uri;
        }
      } catch (error) {
        HiLog.error(TAG, `Error getting ToneAttr ${i} properties: ${JSON.stringify(error)}`);
      }
    }
    return null;
  }

  /**
   * 为「某一类系统铃音」（卡1 短信 / 卡2 短信 / 系统通知）设置铃声。
   * 若当前该类铃声文件名已是 fileInfo.fileName 则仅 toast 并返回；否则创建 toneAttrs 并设置 category，
   * 在铃音库中按文件名查找，找到则 setSystemToneUri 复用，未找到则 addCustomizedTone 后再 setSystemToneUri。最后按需 toast。
   * @param context - UIAbility 上下文
   * @param mgr - 系统铃音管理实例
   * @param fileInfo - 当前选中的音频文件信息
   * @param fd - 已打开的音频文件描述符
   * @param type - 要设置的系统铃音类型（SystemToneType：卡1 短信 / 卡2 短信 / 系统通知）
   * @param category - 铃音分类（如 TONE_CATEGORY_TEXT_MESSAGE、TONE_CATEGORY_NOTIFICATION），用于 setCategory
   * @param currentFileName - 该类当前铃声的文件名，用于判断是否已是同一文件
   * @param toastMsg - 设置成功后的提示文案；空字符串则不 toast
   */
  private async setSystemToneForOneType(
    context: common.UIAbilityContext,
    mgr: systemSoundManager.SystemSoundManager,
    fileInfo: FileInfo,
    fd: number,
    type: systemSoundManager.SystemToneType,
    category: number,
    currentFileName: string | undefined,
    toastMsg: string
  ): Promise<void> {
    if (currentFileName === fileInfo.fileName) {
      HiLog.info(TAG, `System tone already set to ${fileInfo.fileName}`);
      if (toastMsg) {
        toast(toastMsg);
      }
      return;
    }
    const toneAttrs = systemSoundManager.createCustomizedToneAttrs();
    toneAttrs.setTitle(fileInfo.fileName);
    toneAttrs.setFileName(fileInfo.fileName);
    toneAttrs.setCategory(category);
    const targetUri = await this.findSystemToneUriByFileName(context, mgr, type, fileInfo.fileName);
    if (targetUri) {
      HiLog.info(TAG, `System tone already exists in library: ${targetUri}`);
      await mgr.setSystemToneUri(context, targetUri, type);
      HiLog.info(TAG, 'Succeeded in doing setSystemToneUri with existing tone');
    } else {
      const newUri = await mgr.addCustomizedTone(context, toneAttrs, fd, 0);
      HiLog.info(TAG, `Succeeded in doing addCustomizedTone. value=${newUri}`);
      await mgr.setSystemToneUri(context, newUri, type);
      HiLog.info(TAG, 'Succeeded in doing setSystemToneUri');
    }
    if (toastMsg) {
      toast(toastMsg);
    }
  }

  /**
   * 将指定音频文件设为「来电铃声」。
   * 获取卡1、卡2 当前铃声 URI 与文件名；打开文件得到 fd；根据 number 清理铃音库并调用 setRingtoneForOneSim：
   * number=0 仅设卡1，number=1 仅设卡2，number=2 同时设卡1 和卡2。最后在 finally 中关闭文件。
   * @param fileInfo - 选中的音频文件信息（uri、fileName 等）
   * @param number - 0=仅卡1，1=仅卡2，2=卡1 和卡2 同时设定
   */
  private async setRingtone(fileInfo: FileInfo, number: number): Promise<void> {
    HiLog.info(TAG, `setRingtone ${JSON.stringify(fileInfo)}`);
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    HiLog.info(TAG, `文件路径: ${fileInfo.uri}`);
    const mgr = systemSoundManager.getSystemSoundManager();
    const typeSim1 = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
    const typeSim2 = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;

    let currentUriSim1 = '';
    let currentUriSim2 = '';
    try {
      currentUriSim1 = await mgr.getRingtoneUri(context, typeSim1);
      currentUriSim2 = await mgr.getRingtoneUri(context, typeSim2);
    } catch (_) {
      // 忽略单卡未设置等情况
    }
    HiLog.info(TAG, `Current ringtone URISIM1: ${currentUriSim1}, URISIM2: ${currentUriSim2}`);
    const currentFileNameSim1 = currentUriSim1 ? currentUriSim1.split('/').pop() : undefined;
    const currentFileNameSim2 = currentUriSim2 ? currentUriSim2.split('/').pop() : undefined;

    const file = fs.openSync(fileInfo.uri, fs.OpenMode.READ_ONLY);
    const fd = file.fd;
    const keepUris = [currentUriSim1, currentUriSim2].filter(uri => uri !== '');

    try {
      if (number === 0) {
        await this.cleanupRingtoneLibrary(context, mgr, typeSim1, keepUris);
        await this.setRingtoneForOneSim(context, mgr, fileInfo, fd, typeSim1, currentFileNameSim1,
          '已设为卡1的来电铃声');
      } else if (number === 1) {
        await this.cleanupRingtoneLibrary(context, mgr, typeSim2, keepUris);
        await this.setRingtoneForOneSim(context, mgr, fileInfo, fd, typeSim2, currentFileNameSim2,
          '已设为卡2的来电铃声');
      } else if (number === 2) {
        await this.cleanupRingtoneLibrary(context, mgr, typeSim1, keepUris);
        if (currentFileNameSim1 !== fileInfo.fileName) {
          await this.setRingtoneForOneSim(context, mgr, fileInfo, fd, typeSim1, currentFileNameSim1, '');
        }
        if (currentFileNameSim2 !== fileInfo.fileName) {
          await this.setRingtoneForOneSim(context, mgr, fileInfo, fd, typeSim2, currentFileNameSim2, '');
        }
        toast('已设为卡1和卡2的来电铃声');
      }
    } catch (error) {
      HiLog.error(TAG, `setRingtone error ${JSON.stringify(error)}`);
    } finally {
      fs.closeSync(file);
    }
  }

  /**
   * 将指定音频文件设为「闹钟铃声」。
   * 创建闹钟类型的 toneAttrs，打开文件；获取当前闹钟铃声 URI；清理闹钟铃音库（保留当前使用的那条）；
   * 若当前已是同一文件则直接 toast 并返回，否则将文件加入铃音库并 setAlarmToneUri，最后关闭文件并 onClose 关闭菜单。
   * @param fileInfo - 选中的音频文件信息
   */
  private async setAlarmTone(fileInfo: FileInfo): Promise<void> {
    HiLog.info(TAG, `setAlarmTone ${JSON.stringify(fileInfo)}`);
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    HiLog.info(TAG, `文件路径: ${fileInfo.uri}`);
    const mgr = systemSoundManager.getSystemSoundManager();
    const toneAttrs = systemSoundManager.createCustomizedToneAttrs();
    toneAttrs.setTitle(fileInfo.fileName);
    toneAttrs.setFileName(fileInfo.fileName);
    toneAttrs.setCategory(systemSoundManager.TONE_CATEGORY_ALARM);

    const file = fs.openSync(fileInfo.uri, fs.OpenMode.READ_ONLY);
    const fd = file.fd;

    let currentUri = '';
    let currentFileName = '';
    try {
      currentUri = await mgr.getAlarmToneUri(context);
      currentFileName = currentUri.split('/').pop() || '';
      HiLog.info(TAG, `Current AlarmTone URI: ${currentUri}, file name: ${currentFileName}`);
    } catch (error) {
      HiLog.info(TAG, `No current alarm tone found: ${JSON.stringify(error)}`);
    }

    try {
      await this.cleanupAlarmToneLibrary(context, mgr, currentUri);
      if (currentFileName === fileInfo.fileName) {
        HiLog.info(TAG, `AlarmTone already set to ${fileInfo.fileName}`);
        toast('已设为闹钟铃声');
        return;
      }
      const newUri = await mgr.addCustomizedTone(context, toneAttrs, fd, 0);
      HiLog.info(TAG, `Succeeded in doing addCustomizedTone. value=${newUri}`);
      await mgr.setAlarmToneUri(context, newUri);
      HiLog.info(TAG, 'Succeeded in doing setAlarmToneUri');
      toast('已设为闹钟铃声');
    } catch (error) {
      HiLog.error(TAG, `setAlarmTone error ${JSON.stringify(error)}`);
    } finally {
      fs.closeSync(file);
      this.onClose();
    }
  }

  /**
   * 将指定音频文件设为「短信铃声」或「系统通知铃声」。
   * 获取卡1、卡2、系统通知的当前铃音 URI 与文件名；打开文件；根据 number 清理对应系统铃音库并调用 setSystemToneForOneType：
   * number=0 仅设卡1 短信，number=1 仅设卡2 短信，number=2 同时设卡1 和卡2 短信，number=3 设系统通知。finally 中关闭文件，number=3 时额外 onClose 关闭菜单。
   * @param fileInfo - 选中的音频文件信息
   * @param number - 0=卡1 短信，1=卡2 短信，2=卡1 和卡2 短信同时设定，3=系统通知铃声
   */
  private async setMsgNotifTone(fileInfo: FileInfo, number: number): Promise<void> {
    HiLog.info(TAG, `setMsgNotifTone ${JSON.stringify(fileInfo)}`);
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    HiLog.info(TAG, `文件路径: ${fileInfo.uri}`);
    const mgr = systemSoundManager.getSystemSoundManager();
    const typeSim1 = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
    const typeSim2 = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1;
    const typeNotif = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;

    let currentUriSim1 = '';
    let currentUriSim2 = '';
    let currentUriNotif = '';
    try {
      currentUriSim1 = await mgr.getSystemToneUri(context, typeSim1);
    } catch (e) {
      HiLog.info(TAG, `No current system tone for SIM1: ${JSON.stringify(e)}`);
    }
    try {
      currentUriSim2 = await mgr.getSystemToneUri(context, typeSim2);
    } catch (e) {
      HiLog.info(TAG, `No current system tone for SIM2: ${JSON.stringify(e)}`);
    }
    try {
      currentUriNotif = await mgr.getSystemToneUri(context, typeNotif);
    } catch (e) {
      HiLog.info(TAG, `No current system tone for Notif: ${JSON.stringify(e)}`);
    }

    const currentFileNameSim1 = currentUriSim1 ? currentUriSim1.split('/').pop() : '';
    const currentFileNameSim2 = currentUriSim2 ? currentUriSim2.split('/').pop() : '';
    const currentFileNameNotif = currentUriNotif ? currentUriNotif.split('/').pop() : '';
    HiLog.info(TAG,
      `Current system tone file names SIM1: ${currentFileNameSim1}, SIM2: ${currentFileNameSim2}, Notif: ${currentFileNameNotif}`);
    const keepUris = [currentUriSim1, currentUriSim2, currentUriNotif].filter(uri => uri !== '');
    const file = fs.openSync(fileInfo.uri, fs.OpenMode.READ_ONLY);
    const fd = file.fd;

    try {
      if (number === 0) {
        await this.cleanupSystemToneLibrary(context, mgr, typeSim1, keepUris);
        await this.setSystemToneForOneType(context, mgr, fileInfo, fd, typeSim1,
          systemSoundManager.TONE_CATEGORY_TEXT_MESSAGE, currentFileNameSim1, '已设为卡1的短信铃声');
      } else if (number === 1) {
        await this.cleanupSystemToneLibrary(context, mgr, typeSim2, keepUris);
        await this.setSystemToneForOneType(context, mgr, fileInfo, fd, typeSim2,
          systemSoundManager.TONE_CATEGORY_TEXT_MESSAGE, currentFileNameSim2, '已设为卡2的短信铃声');
      } else if (number === 2) {
        await this.cleanupSystemToneLibrary(context, mgr, typeSim1, keepUris);
        if (currentFileNameSim1 !== fileInfo.fileName) {
          await this.setSystemToneForOneType(context, mgr, fileInfo, fd, typeSim1,
            systemSoundManager.TONE_CATEGORY_TEXT_MESSAGE, currentFileNameSim1, '');
        }
        if (currentFileNameSim2 !== fileInfo.fileName) {
          await this.setSystemToneForOneType(context, mgr, fileInfo, fd, typeSim2,
            systemSoundManager.TONE_CATEGORY_TEXT_MESSAGE, currentFileNameSim2, '');
        }
        toast('已设为卡1和卡2的短信铃声');
      } else if (number === 3) {
        await this.cleanupSystemToneLibrary(context, mgr, typeNotif, keepUris);
        await this.setSystemToneForOneType(context, mgr, fileInfo, fd, typeNotif,
          systemSoundManager.TONE_CATEGORY_NOTIFICATION, currentFileNameNotif, '已设为通知铃声');
      }
    } catch (error) {
      HiLog.error(TAG, `setMsgNotifTone error ${JSON.stringify(error)}`);
    } finally {
      fs.closeSync(file);
      if (number === 3) {
        this.onClose();
      }
    }
  }
}