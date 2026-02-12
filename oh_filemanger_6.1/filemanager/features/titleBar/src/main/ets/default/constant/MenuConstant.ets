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
export interface MenuIcons {
  back: Resource,
  cancel: Resource,
  addFolder: Resource,
  all: Resource,
  selectAll: Resource,
  pickerOk: Resource,
  delete: Resource,
  more: Resource,
  switchGrid: Resource,
  switchList: Resource,
  multipleChoice: Resource,
  detail: Resource,
  copy: Resource,
  rename: Resource,
  restore: Resource,
  move: Resource,
  otherApp: Resource,
  help: Resource,
  refresh: Resource,
  search: Resource,
}

export interface MenuName {
  back: Resource,
  cancel: Resource,
  close: Resource,
  cancelSelectAll: Resource,
  selectAll: Resource,
  more: Resource,
  help: Resource,
  delete: Resource,
  copy: Resource,
  refresh: Resource,
  add: Resource,
  listIcon: Resource,
  listList: Resource,
  orderTime: Resource,
  orderSize: Resource,
  orderType: Resource,
  default: Resource,
  name: Resource,
  deleteAll: Resource,
  mineHelp: Resource,
  checkVersion: Resource,
  about: Resource,
  edit: Resource,
  multipleChoice: Resource,
  select: Resource,
  move: Resource,
  rename: Resource,
  detail: Resource,
  rotate: Resource,
  otherApp: Resource,
  setAsWallpaper: Resource,
  search: Resource,
}

export const MENU_ICONS: MenuIcons = {
  back: $r('sys.symbol.chevron_backward'),
  cancel: $r('sys.symbol.xmark'),
  addFolder: $r('app.media.hidisk_ic_menu_add_nor'),
  all: $r('sys.symbol.checkmark_square_on_square'),
  selectAll: $r('sys.symbol.checkmark_square_on_square_fill'),
  pickerOk: $r('sys.symbol.checkmark'),
  delete: $r('sys.symbol.ohos_trash'),
  more: $r('sys.symbol.dot_grid_2x2'),
  switchGrid: $r('sys.symbol.square_grid_2x2'),
  switchList: $r('sys.symbol.list_bullet'),
  multipleChoice: $r('sys.symbol.checkmark_circle'),
  detail: $r('sys.symbol.doc_text'),
  rename: $r('sys.symbol.rename'),
  copy: $r('sys.symbol.plus_square_on_square'),
  restore: $r('sys.symbol.arrow_clockwise'),
  move: $r('sys.symbol.arrow_right_folder_circle'),
  otherApp: $r('sys.symbol.arrow_right_up_and_square'),
  help: $r('sys.symbol.questionmark_circle'),
  refresh: $r('sys.symbol.arrow_counterclockwise'),
  search: $r('sys.symbol.magnifyingglass'),
}

export const MENU_NAME: MenuName = {
  back: $r('app.string.go_back'),
  cancel: $r('app.string.cancel'),
  close: $r('app.string.close'),
  add: $r('app.string.addFolder'),
  cancelSelectAll: $r('app.string.cancel_all_selection'),
  selectAll: $r('app.string.select_all'),
  more: $r('app.string.more'),
  help: $r('app.string.help_and_feedback'),
  delete: $r('app.string.delete'),
  copy: $r('app.string.copy'),
  refresh: $r('app.string.refresh'),
  listIcon: $r('app.string.list_icon'),
  listList: $r('app.string.list_list'),
  orderTime: $r('app.string.order_time'),
  orderSize: $r('app.string.order_size'),
  orderType: $r('app.string.order_type'),
  default: $r('app.string.default'),
  name: $r('app.string.name'),
  deleteAll: $r('app.string.delete_all'),
  mineHelp: $r('app.string.help_and_feedback'),
  checkVersion: $r('app.string.check_version'),
  about: $r('app.string.setting_title_about'),
  edit: $r('app.string.edit'),
  multipleChoice: $r('app.string.multiple_choices'),
  select: $r('app.string.select'),
  move: $r('app.string.move'),
  rename: $r('app.string.rename'),
  detail: $r('app.string.file_details'),
  rotate: $r('app.string.rotate'),
  otherApp: $r('app.string.otherApp'),
  setAsWallpaper: $r('app.string.set_as_wallpaper'),
  search: $r('app.string.search'),
}

export enum TitleAnimation {
  BACK_BUTTON_IN_DELAY = 100,
  BACK_BUTTON_IN_DURATION = 200,
  BACK_BUTTON_OUT_DURATION = 67,
  TITLE_IN_DELAY = 33,
  TITLE_IN_DURATION = 150,
  TITLE_OUT_DELAY = 30,
  TITLE_OUT_DURATION = 450,
  TITLE_IN_TRANSLATE = 50,
  TITLE_OUT_TRANSLATE = 300
}