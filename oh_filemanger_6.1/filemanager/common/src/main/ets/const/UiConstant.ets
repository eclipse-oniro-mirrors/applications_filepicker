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
import { WindowModelData } from '../model/WindowModelData';

import {
  ZIndex,
  BottomBarColor,
  SystemBarColor,
  BottomBarMap,
} from '../model/Common';
import { MenuItemName } from '../menu/MenuInfo';
import { Constant } from '../const/Constant';

export const Z_INDEX: ZIndex = {
  TOP: 999,
  MIDDLE: 99,
  LOW: 9,
  LEVEL10: 10,
  LEVEL100: 100,
  LEVEL101: 101
}

export const TREE_LAYER: number = 12;

export const BOTTOM_BAR_COLOR: BottomBarColor = {
  enabled: 1,
  disabled: 0.3
}

export const SYSTEM_BAR_COLOR: SystemBarColor = {
  WHITE: new WindowModelData($r('sys.color.ohos_id_color_statusbar_bg'), $r('sys.color.ohos_id_color_background')),
  BLACK: new WindowModelData($r('sys.color.ohos_id_color_foreground'), $r('sys.color.ohos_id_color_background')),
  LIGHT_GRAY: new WindowModelData($r('sys.color.ohos_id_color_focused_content_tertiary'), $r('sys.color.ohos_id_color_background')),
  PATH_PICK: new WindowModelData($r('sys.color.ohos_id_color_sub_background'), $r('sys.color.ohos_id_color_background')),
  PATH_PICK_DARK: new WindowModelData($r('sys.color.ohos_id_color_sub_background_dark'), $r('sys.color.ohos_id_color_background')),
}

export const BOTTOM_BAR_MAP: BottomBarMap = {
  copy: $r('app.string.copy'),
  pasting: $r('app.string.pasting'),
  move: $r('app.string.move'),
  delete: $r('app.string.delete_upper_camelcase'),
  play: $r('app.string.play'),
  pause: $r('app.string.pause'),
  more: $r('app.string.more'),
  details: $r('app.string.file_details'),
  otherLocation: $r('app.string.OtherLocation'),
  restore: $r('app.string.restore'),
  selectAll: $r('app.string.menu_select_all'),
  deselectAll: $r('app.string.menu_deselect_all'),
  rotate: $r('app.string.rotate'),
  rename: $r('app.string.rename'),
}

export const moreMap: Record<string, Resource> = {
  'move': $r('app.string.move'),
  'rename': $r('app.string.rename'),
  'detail': $r('app.string.file_details'),
  'rotate': $r('app.string.rotate'),
  'otherApp': $r('app.string.otherApp'),
  'openFolder':  $r('app.string.openFolder'),
  'favorite': $r('app.string.favorite'),
  'unfavorite': $r('app.string.unfavorite'),
  'clearRecentRecord': $r('app.string.clear_recent_record'),
  'setAsWallpaper': $r('app.string.set_as_wallpaper')
}

export interface MenuIcons {
  back: Resource,
  cancel: Resource,
  close: Resource,
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
  favorite: Resource,
  unFavorite: Resource,
  setWallpaper: Resource,
  setRingtone: Resource,
  print: Resource,
  openFolder: Resource,
  rotateImage: Resource,
  edit: Resource,
  clean: Resource,
  remove: Resource,
  unFavourite: Resource
}

export const MENU_ICONS: MenuIcons = {
  back: $r('sys.symbol.chevron_backward'),
  cancel: $r('sys.symbol.xmark'),
  close: $r('sys.symbol.xmark'),
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
  favorite: $r('sys.symbol.star'),
  unFavorite: $r('sys.symbol.star_fill'),
  setWallpaper: $r('sys.symbol.picture'),
  setRingtone: $r('sys.symbol.bell'),
  print: $r('sys.symbol.printer'),
  openFolder: $r('sys.symbol.folder'),
  rotateImage: $r('sys.symbol.rotate_left'),
  edit: $r('sys.symbol.square_and_pencil'),
  clean: $r('sys.symbol.clean'),
  remove: $r('sys.symbol.minus_circle'),
  unFavourite: $r('sys.symbol.heart_slash')
}

export interface MENU_ITEM_CONTENT {
  content: ResourceStr;
  event: string;
  icon: Resource;
}

export const MENU_ITEM_MAP: Map<number, MENU_ITEM_CONTENT> = new Map<number, MENU_ITEM_CONTENT>([
  [MenuItemName.OPEN_FOLDER,
    { content: $r('app.string.open_folder'), event: Constant.EVENTS.LONG_PRESS_OPEN_FOLDER, icon: MENU_ICONS.openFolder }],
  [MenuItemName.OPEN_BY_OTHER_APP,
    { content: $r('app.string.otherApp'), event: Constant.EVENTS.LONG_PRESS_OTHER_APP, icon: MENU_ICONS.otherApp }],
  [MenuItemName.FAVORITE, { content: $r('app.string.favorite'), event: Constant.EVENTS.LONG_PRESS_FAVORITE,
    icon: MENU_ICONS.favorite }],
  [MenuItemName.UN_FAVORITE, { content: $r('app.string.unfavorite'), event: Constant.EVENTS.LONG_PRESS_UNFAVORITE,
    icon: MENU_ICONS.unFavorite }],
  [MenuItemName.PRINT, { content: $r('app.string.print'), event: Constant.EVENTS.LONG_PRESS_PRINT,
    icon: MENU_ICONS.print }],
  [MenuItemName.SET_RINGTONE, { content: $r('app.string.ringtone'), event: Constant.EVENTS.LONG_PRESS_RINGTONE,
    icon: MENU_ICONS.setRingtone }],
  [MenuItemName.SET_WALLPAPER, { content: $r('app.string.set_as_wallpaper'), event: Constant.EVENTS.LONG_PRESS_WALLPAPER,
    icon: MENU_ICONS.setWallpaper }],
  [MenuItemName.MULTIPLE_CHOICES,
    { content: $r('app.string.multiple_choices'), event: Constant.EVENTS.LONG_PRESS_SELECT,
      icon: MENU_ICONS.multipleChoice }],
  [MenuItemName.MOVE, { content: $r('app.string.move'), event: Constant.EVENTS.LONG_PRESS_MOVE,
    icon: MENU_ICONS.move }],
  [MenuItemName.COPY, { content: $r('app.string.copy'), event: Constant.EVENTS.LONG_PRESS_COPY, icon: MENU_ICONS.copy }],
  [MenuItemName.RENAME, { content: $r('app.string.rename'), event: Constant.EVENTS.LONG_PRESS_RENAME,
    icon: MENU_ICONS.rename }],
  [MenuItemName.DETAILS, { content: $r('app.string.details'), event: Constant.EVENTS.LONG_PRESS_DETAIL,
    icon: MENU_ICONS.detail }],
  [MenuItemName.DELETE, { content: $r('app.string.delete'), event: Constant.EVENTS.LONG_PRESS_DELETE,
    icon: MENU_ICONS.delete }],
  [MenuItemName.RESTORE, { content: $r('app.string.restore'), event: Constant.EVENTS.LONG_PRESS_RESTORE,
    icon: MENU_ICONS.restore }],
]);

export const MORE_MENU_ICON_MAP: Map<string, Resource> = new Map<string, Resource>([
  [Constant.OPERATION_TYPE.ROTATE, MENU_ICONS.rotateImage],
]);

export enum BreakPoint {
  XS = 320,
  SM = 600,
  MD = 840
}

export class HdsUIConfig {
  /**
   * 高端精致适配标题栏高度
   */
  public static readonly HDS_TITLE_HEIGHT = 56;

}

// HomePage页面 Hds菜单参数
export interface HdsMenuItemParam {
  // 菜单标签
  label: Resource,
  // 菜单点击回调
  clickFunc: () => void
}