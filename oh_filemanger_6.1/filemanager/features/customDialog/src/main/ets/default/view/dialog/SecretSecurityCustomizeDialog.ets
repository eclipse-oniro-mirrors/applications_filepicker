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
import { Constant, EventBus, getResourceString, HiLog } from '@ohos/common';
import { DialogButton, DialogButtonDivider, DialogTitle } from './DialogComponent';
import inputMethod from '@ohos.inputMethod';


const TAG = 'SecretSecurityCustomizeDialog';

@CustomDialog
export struct SecretSecurityCustomizeDialog {
  controller?: CustomDialogController;
  @State canClick: boolean = false;
  @Link question: Array<SelectOption>;
  private questionName: string = '';
  // 是否为第一个密保问题
  private isFirstSecretSecurity: boolean = false;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  isCanClick(question: string) {
    this.canClick = question.length > 0 ? true : false;
  }

  closeDialog(): void {
    if (this.controller) {
      EventBus.emit(Constant.EVENTS.CUSTOMIZE_QUESTION, this.questionName, this.isFirstSecretSecurity);
      this.controller.close();
      try {
        inputMethod.getController().hideTextInput();
      } catch (err) {
        HiLog.info(TAG, `keyBoardHeight ${err}`)
      }
    }
  }

  confirmClick() {
    let flag = false;
    for (let index = 0; index < this.question.length; index++) {
      if (this.question[index].value as string === this.questionName ||
        getResourceString(this.question[index].value as Resource) === this.questionName) {
        flag = true;
        break;
      }
    }
    if (!flag) {
      this.question.splice(0, 0, { value: this.questionName })
    }
    this.closeDialog();
    try {
      inputMethod.getController().hideTextInput();
    } catch (err) {
      HiLog.info(TAG, `keyBoardHeight ${err}`)
    }
  }

  build() {
    Column() {
      DialogTitle({
        title: $r('app.string.secret_security_question_six')
      })

      Column() {
        TextInput()
          .margin({
            left: $r('app.float.text_input_margin_minus16'),
            right: $r('app.float.text_input_margin_minus16')
          })
          .borderRadius(0)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .backgroundColor($r('app.color.text_input_bg_color'))
          .draggable(false)
          .defaultFocus(true)
          .onChange((newValue: string) => {
            this.questionName = newValue;
            this.isCanClick(this.questionName);
          })
        Divider()
          .vertical(false)
          .strokeWidth('1px')
          .color($r('sys.color.ohos_id_color_primary'))
          .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
      }
      .margin({
        left: $r('app.float.common_margin24'),
        right: $r('app.float.common_margin24')
      })


      Row() {
        DialogButton({
          text: $r('app.string.cancel'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.closeDialog();
          }
        })
        DialogButtonDivider()
        DialogButton({
          text: $r('app.string.confirm'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: !this.canClick,
          click: () => {
            this.confirmClick();
          }
        })
      }
      .padding({
        top: $r('app.float.common_margin8'),
        bottom: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
    }
  }
}