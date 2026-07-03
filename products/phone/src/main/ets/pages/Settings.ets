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
import { Constant, HiLog, ResourceUtil, ToolBarStyle } from "@ohos/common"

const TAG: string = 'Settings'
// 持久化
PersistentStorage.persistProp(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME, true)

@Builder
export function SettingsBuilder(name: string, param: Object) {
  Settings()
}

@Component
export struct Settings {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State isOn: boolean = (AppStorage.get(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) !== undefined)
    ? AppStorage.get(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) as boolean : true

  aboutToAppear(): void {
    this.isOn = (AppStorage.get(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) !== undefined)
      ? AppStorage.get(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) as boolean : true
  }

  build() {
    NavDestination() {
      Column({ space: 24 }) {
        // 标题栏
        Row() {
          Text($r('app.string.set_up'))
            .fontSize(24)
            .fontWeight(900)

          Blank()

          Button() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontColor([$r('sys.color.ohos_id_color_primary')])
              .fontSize($r('app.float.common_size18'))
              .draggable(false)
              .focusable(true)
          }
          .accessibilityText(ResourceUtil.getStringByResource($r('app.string.cancel')))
          .width($r('app.float.common_size40'))
          .height($r('app.float.common_size40'))
          .padding($r('app.float.common_size11'))
          .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
          .onClick(() => {
            // 返回上一页
            this.pageInfos.pop()
          })
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        }
        .width('100%')

        Row() {
          Column() {
            Text($r('app.string.show_hidden_files'))
              .fontWeight(700)
              .lineHeight(20)

            Text($r('app.string.show_files_with_dot'))
              .fontSize(14)
              .fontColor(Color.Grey)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.isOn })
            .onChange((isOn: boolean) => {
              //存储开关状态
              AppStorage.setOrCreate(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME, isOn)
              HiLog.info(TAG, `showHiddenItem :${isOn}`)
            })
        }
        .width('100%')
      }
      .padding({
        top: $r('app.float.common_padding24'),
        right: $r('app.float.common_padding24'),
        bottom: $r('app.float.common_padding24'),
        left: $r('app.float.common_padding24')
      })
      .width('100%')
      .height('100%')
      .borderRadius({ topLeft: $r('app.float.common_size24'), topRight: $r('app.float.common_size24') })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}