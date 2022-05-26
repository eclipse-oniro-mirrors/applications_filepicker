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

export class DisplayInfo {
  width: number
  height: number
  mainDialogWidth: number
  mainDialogHeight: number
}

export function displayChange(length: number) {
  if (globalThis.width == 720 && globalThis.height == 1280) {
    return (length) * 1.3
  } else {
    return length
  }
}