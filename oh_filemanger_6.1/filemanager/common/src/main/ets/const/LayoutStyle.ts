/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

export enum LeftBarSize {
  INITIAL_WIDTH = 240,
  MIN_WIDTH = 240,
  MAX_WIDTH = 280,
  LEFT_BAR_IMAGE_PADDING = 4, // 图标距图片框的距离
  LEFT_BAR_TEXT_PADDING = 9 - LEFT_BAR_IMAGE_PADDING, // 快速访问距最近距离
  LEFT_BAR_ROW_SPACE = 4, // 左侧导航栏列表项上下间距
  LEFT_BAR_COL_COMP_PADDING_BOTTOM = 8, // 导航栏标题下间距
  LEFT_BAR_GROUP_PADDING = 16, //侧边栏组边距
  LEFT_BAR_COL_ITEM_HEIGHT = 42, // 导航栏选项高度
  LEFT_BAR_GROUP_SPACE = 8, // 列表分组间距
  LEFT_BAR_GROUP_SPACE_PAD = 0,
  LEFT_BAR_LIST_SPACE = 2, // 列表行间距
  LEFT_BAR_LIST_SPACE_PAD = 0,
  LEFT_BAR_ANIMATE_DURATION = 250, // 动效持续时长
  ANIMATION_VELOCITY = 0, // 动效物理曲线初始速度值
  ANIMATION_MASS = 1, // 动效物理曲线质量值
  ANIMATION_STIFFNESS = 240, // 动效物理曲线刚度值
  ANIMATION_DAMPING = 28, // 动效物理曲线阻尼值
  PROPERTY_BAR_LEFT = 24, // 属性栏左侧间距
  PROPERTY_BAR_RIGHT = 24 // 属性栏右侧间距
}

export enum FileListViewStyle {
  PADDING_TOP = 8,
  PADDING_BOTTOM = 0,
  FILE_LIST_BORDER_WIDTH = 2,
  FILE_LIST_PADDING_LEFT = 24 - FILE_LIST_BORDER_WIDTH, // 选中框左边距侧边栏的距离
  FILE_LIST_PADDING_RIGHT = 24 - FILE_LIST_BORDER_WIDTH, // 选中框右边距右侧窗口的距离
  MUL_FILE_LIST_FIRST_ROW_PADDING_LEFT = 12,
  FILE_LIST_FIRST_ROW_PADDING_LEFT = 12, // 图标距左边距选中框的距离
  PAD_MUL_FILE_LIST_FIRST_ROW_PADDING_LEFT = 8,
  PAD_FILE_LIST_FIRST_ROW_PADDING_LEFT = 8, // PAD图标距左边距选中框的距离
  FILE_LIST_FIRST_ROW_PADDING_RIGHT = 24,
  FILE_LIST_CHECKBOX_OFFSET = -2, // Checkbox组件到外层Row组件左边框偏移量
  FILE_LIST_CHECKBOX_WIDTH = 30, // Checkbox组件宽度
  FILE_LIST_NAME_COLUMN_RIGHT_PADDING = 20, // 列表视图名称列右边距，防止标签和文字重叠
  FILE_LIST_MARGIN_LEFT = 6,
  FILE_LIST_MARGIN_RIGHT = 0,
  FILE_LIST_HEIGHT = 40,
  FILE_LIST_HEIGHT_PAD = 56,
  FILE_LIST_DATA_PADDING_LEFT = 12,
  FILE_LIST_DATA_PADDING_RIGHT = 4,
  LIST_IMAGE_WIDTH = 24,
  LIST_IMAGE_HEIGHT = 24,
  LIST_IMAGE_WIDTH_PAD = 36,
  LIST_IMAGE_HEIGHT_PAD = 36,
  LIST_IMAGE_MARGIN_RIGHT = 6,
  LIST_IMAGE_MARGIN_RIGHT_PAD = 8,
  LIST_TAG_WIDTH = 12,
  LIST_ITEM_BORDER_RADIUS = 8,
  LIST_ITEM_BORDER_RADIUS_PAD = 16,
  TEXT_INPUT_MIN_WIDTH = 16,
  TEXT_INPUT_MIN_HEIGHT = 22,
}

export enum HoverPopupStyle {
  HOVER_MENU_MAX_WIDTH = 604,
  HOVER_DEFAULT_TAG_MAX_WIDTH = 400,
  BIND_POPUP_TARGET_SPACE = 8,
  HOVER_MENU_FONT_SIZE = 14,
  HOVER_MENU_HORIZON_PADDING = 16,
  HOVER_MENU_VERTICAL_PADDING = 8,
  HOVER_MENU_TEXT_OPACITY = 0.6,
  HOVER_MENU_LINE_HEIGHT = 19,
  HOVER_MENU_BORDER_RADIUS = 16,
  ADDRESS_BAR_HOVER_HEIGHT_LIMIT = 20,
  POPUP_TIP_RADIUS = 8, // 气泡提示圆角
}

export enum ToolBarStyle {
  TOOLBAR_HEIGHT = 56,
  TOOLBAR_PADDING_LEFT_AND_RIGHT = 16,
  ITEM_IMG_WIDTH = 20,
  ITEM_PADDING = 6,
  ITEM_BORDER_RADIUS = 24,
  ITEM_CORNER_RADIUS = 8,
  ITEM_MARGIN_LEFT = 4,
  RIGHT_MENU_ITEM_RADIUS = 12,
  CHOSEN_TEXT_HEIGHT_LIMIT = 24,
  BACK_NEXT_COMP_PADDING_LEFT = 0, // 前进后退按钮hover背景色左侧距侧边栏间距
  BACK_NEXT_COMP_PADDING_RIGHT = 8,
  MUL_CHOICES_COMP_PADDING_LEFT = 0, // 多选取消按钮hover背景色左侧距侧边栏间距
  MUL_CHOICES_COMP_PADDING_RIGHT = 16,
  ADD_TAG_SUB_MENU_WIDTH = 159, // 添加标签子菜单宽度
  RIGHT_PADDING_WIDTH = 132, // 16(距离三键的边距) + 24 *3 （三键按钮的宽度） + 12 * 2（三键之间的间隔） + 20（关闭按钮距离右边距）
  PICKER_ABILITY_PADDING_WIDTH = 96, // 16(距离2键的边距) + 24 *2 （2键按钮的宽度） + 12（2键之间的间隔） + 20（关闭按钮距离右边距）
  PICKER_UI_PADDING_WIDTH = 60, // 16(距离关闭键的边距) + 24 （关闭按钮的宽度）+ 20（关闭按钮距离右边距）
  PICKER_SERVICE_PADDING_WIDTH = 20, // 20（关闭按钮距离右边距）
  BOTTOM_BAR_HEIGHT = 52, // 工具栏高度52
}

export enum DialogStyle {
  TEXT_FONT_SIZE = 16,
  TITLE_FONT_SIZE = 20
}

export enum TabBarStyle {
  SINGLE_SCREEN_HEIGHT = 48, // 文档说明设置BottomTabBarStyle样式且vertical属性为false时，默认值为48vp
  FOLD_EXPANDED_HEIGHT = 40  // 折叠屏展开态，tabBar内图标和文字为左右显示，UX给出高度设置为40
}