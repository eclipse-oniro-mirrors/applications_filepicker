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

/**
 * 界面元素id，便于自动化用例设计的时候捕捉操作控件属性
 * 确保元素id唯一
 */
export enum CompId {
  /* 主界面 */
  BROWSE_PAGE = 'browse_page', // 浏览界面
  MYPHONE_PAGE = 'myphone_page', // 我的手机界面
  TOP_MENU = 'top_menu', // 顶部菜单栏
  TOP_TITLE = 'top_title', // 顶部标题栏
  EXPAND_BUTTON = 'expand_button', // 导航栏展开隐藏按钮

  TOP_BUTTON = 'top_button', // 顶部按钮

  LEFT_ICON = 'left_icon', // 返回
  CANCEL_ICON = 'cancel_icon', // 取消
  NEW_DOCUMENT_ICON = 'new_document_icon', // 新建文件

  FOLDER_ICON = 'folder_icon', // 文件夹图标
  NEW_FOLDER_ICON = 'new_folder_icon', // 新建文件夹

  // 排序
  MENU_UP = 'menu_up', // 上升
  MENU_DOWN = 'menu_down', // 下降
  LIST_OR_GRID_BUTTON = 'list_or_grid_button', // 列表或宫格视图按钮

  // 弹窗
  RENAME_DIALOG_INPUT = 'rename_dialog_input', // 重命名输入框
  DIALOG_CONFIRM = 'dialog_confirm', // 弹窗确认按钮
  DIALOG_CANCEL = 'dialog_cancel', // 弹窗取消按钮
  DIALOG_TITLE = 'dialog_title', // 弹窗标题
  DIALOG_MIN_TITLE = 'dialog_min_title', // 弹窗小标题
  DIALOG_DOCUMENT_MEMORY = 'dialog_document_memory', // 移动/复制的文件大小
  DIALOG_NEW_DOCUMENT_INPUT = 'dialog_new_document_input', // 新建文件夹

  NAVIGATIONFIELD__TEXT__MAINTITLE = '__NavigationField__Text__MainTitle__', // navigation标题
  FILE_ITEM = 'file_item', // 无障碍文件获焦
  FILE_ITEM_PICKER = 'file_item_picker', // picker模式无障碍文件获焦
  NO_CONTENT = 'no_content', // 没有文件
  NO_CONTENT_PICKER = 'no_content_picker', // picker模式没有文件
  PAF_MINE_BOTTOM_LIST_ITEM_BUILDER_ROW = 'Paf_Mine_Bottom_List_Item_Builder_Row', // 关于-版本信息


  EXPEND_VIEW_IMAGE = 'media_expend_view',
  POPOVER_DIALOG = 'PopoverDialog',
  TRASH_SYMBOL = 'symbol_trash',
  DUPLICATE_FILES_LISTVIEW_END_ICON = 'Duplicate_Files_ListView_end_icon',
  DUPLICATE_FILE_ICON_END_ICON = 'Duplicate_FileIcon_end_icon',
  BIGSIZE_CATEGORY_TITLE = 'BigSize_Category_Title',
  FILES_CATEGORY_ITEM = 'Files_Category_Item',
  IMAGE_SIZE_FILTER_CUSTOM_INPUT = 'Image_Size_Filter_Custom_Input'
}

// 震动反馈触发方式
export enum VibrateType {
  LONG_PRESS = 'longPress', // 长按震动反馈
  DRAG_UP = 'dragUp' // 拖起震动反馈
}