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

export enum menuLevel {
  MENU_FIRST_LEVEL_BY_TYPE = 1,
  MENU_SECOND_LEVEL_BY_FOLD = 2,
  MENU_THIRD_LEVEL_HAS_PIC = 3,
  MENU_THIRD_LEVEL_HAS_DETAIL = 4,
}

export enum media_type {
  MEDIA_TYPE_FILE = 1,
  MEDIA_TYPE_IMAGE = 3,
  MEDIA_TYPE_VIDEO = 4,
  MEDIA_TYPE_AUDIO = 5,
  MEDIA_TYPE_ALBUM = 8
}

export enum GridItemSize {
  GRID_ITEM_HEIGHT = 126,
  GRID_ITEM_WIDTH = 96,
  GRID_ITEM_COLUMNS_GAP = 8,
  GRID_ITEM_ROWS_GAP = 8,
}

export enum terminate_reason {
  SUCCESS = 0,
  NO_ACTION = -1,
}

export enum pad_size {
  MAIN_DIALOG_WIDTH = 752,
  MAIN_DIALOG_HEIGHT = 502,
  LEFT_DIALOG_WIDTH = 200,
  LEFT_DIALOG_HEIGHT = 332,
  RIGHT_DIALOG_WIDTH = 544,
  RIGHT_DIALOG_HEIGHT = 332,
  BOTTOM_WIDTH = 744,
  BOTTOM_HEIGHT = 120,

  IC_PUBLIC_FOLDER_WIDTH = 24,
  IC_PUBLIC_FOLDER_HEIGHT = 24,
  ONE = 1,
  TWO = 2,
  FOUR = 4,
  EIGHT = 8,
  NINE = 9,
  TEN = 10,
  ELEVEN = 11,
  TWELVE = 12,
  FOURTEEN = 14,
  SIXTEEN = 16,
  SEVENTEEN = 17,
  EIGHTEEN = 18,
  NINETEEN = 19,
  TWENTY = 20,
  TWENTY_ONE = 21,
  TWENTY_TWO = 22,
  TWENTY_FOUR = 24,
  TWENTY_SEVEN = 27,
  TWENTY_NINE = 29,
  THIRTY = 30,
  THIRTY_TWO = 32,
  FORTY = 40,
  FORTY_SIX = 46,
  FIFTY_SIX = 56,
  SIXTY_FOUR = 64,
  EIGHTY = 80,
  EIGHTY_TWO = 82,
  EIGHTY_EIGHT = 88,
  NINETY_SIX = 96,
  ONE_HUNDRED_AND_FOUR = 104,
  ONE_HUNDRED_AND_THIRTY_FOUR = 134,
  ONE_HUNDRED_AND_SEVENTY_SIX = 176,
  ONE_HUNDRED_AND_SEVENTY_EIGHT = 178,
  TWO_HUNDRED_AND_SIXTY = 260,
  THREE_HUNDRED_AND_FORTY = 340,
  FOUR_HUNDRED = 400,
  FIVE_HUNDRED_AND_FOUR = 504,
  SIX_HUNDRED_AND_NINE = 609,
  SEVEN_HUNDRED_AND_FOURTEEN = 714,
}

export enum mediaName {
  IMAGE = '图片',
  VIDEO = '视频',
  AUDIO = '音乐',
  DOCUMENT = '文档',
  FILE_TYPE = "文件类型"
}