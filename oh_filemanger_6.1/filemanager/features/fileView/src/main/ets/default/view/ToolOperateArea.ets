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

import {
  HiLog,
  PAGE_ROUTE_CONST,
  SortOrder,
  TopMenuDivider,
  ViewMode,
  Constant,
  ResourceUtil,
  UserState,
  PreferenceConst,
  AccessibilityManager,
  getResourceString,
  CompId,
  VIEW_MODE,
  FilePickerUtil
} from '@ohos/common';
import { MENU_NAME, TopMenuItem } from '@ohos/titleBar';
import { TopMenu } from '@ohos/titleBar';
import { SymbolIconButton } from '../viewModel/SymbolIconControl';
import { Callback } from '@kit.BasicServicesKit';

const TAG: string = 'ToolOperateArea';

export enum ToolOperateType {
  NEW_FOLDER,
  VIEW_CHANGE_LIST,
  VIEW_CHANGE_GRID,
  CLEAR_FILES,
  FILES_FILTER
}

const sortMap: Map<string, Resource> = new Map<string, Resource>([
  [SortOrder.DEFAULT, $r('app.string.sort_by_default')],
  [SortOrder.NAME, $r('app.string.sort_by_name')],
  [SortOrder.TIME, $r('app.string.sort_by_time')],
  [SortOrder.SIZE, $r('app.string.sort_by_size')],
  [SortOrder.TYPE, $r('app.string.sort_by_type')]])

@Component
export struct ToolOperateArea {
  public onClickCallback: Callback<ToolOperateType> = (operateType: number) => {}
  public pageName: string = '';
  public isFileSourceView: boolean = false;
  @Link currentFolder: string;
  @State curFileViewType: ViewMode = ViewMode.LIST;
  @Consume viewMode: string;
  @Consume @Watch('onSelectOrderAccept') order: string;
  @Consume @Watch('onSelectOrderAccept') isDesc: boolean;

  @State showTopMenu: boolean = false;
  @State sortMenuArray: TopMenuItem[] = [];
  @State sortTypeResource: Resource = $r('app.string.sort_by_default');

  public isPickerFlag: boolean = false;
  @Prop isSuffixFilter: boolean = false;
  @Prop userState: UserState = UserState.BROWSER;
  @Prop isShowLoading: boolean = false;
  public customTheme: CustomTheme = FilePickerUtil.getStartOptionsFromStorage().customTheme;

  aboutToAppear(): void {
    HiLog.info(TAG, `ToolOperateArea, pageName: ${this.pageName}, viewModeKey: ${this.viewMode}`);
    this.initSortMenu();
    this.curFileViewType = this.viewMode as ViewMode;
  }

  showCreateFolder(): boolean {
    HiLog.info(TAG, 'showCreateFolder');
    if (this.isPickerFlag || this.isFileSourceView) {
      return false;
    }
    // 路径改变时，触发currentFolder改变，获取是否为图库路径
    if (this.currentFolder?.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      return false;
    }
    if (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
      return false;
    }
    return true;
  }

  onSelectOrderAccept(): void {
    this.initSortMenu();
  }

  build() {
    Column() {
      RelativeContainer() {
        // 新建文件夹，最左边
        if (this.showCreateFolder()) {
          SymbolIconButton({
            symbolResource: $r('sys.symbol.folder_badge_plus'),
            fontColorResource: [$r('sys.color.ohos_id_color_primary')],
            accessibilityTxt: ResourceUtil.getStringByResource($r('app.string.create_new_folder')),
            clickCallback: () => {
              HiLog.warn(TAG, 'create folder.');
              this.onClickCallback(ToolOperateType.NEW_FOLDER);
            }
          })
            .alignRules({
              left: { anchor: 'file_filter', align: HorizontalAlign.Start },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .id('create_folder')
            .enabled(this.isEnabledStatus())
            .opacity(this.getOpacityVal())
        }

        // 垃圾箱，最左边
        if (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
          SymbolIconButton({
            symbolResource: $r('sys.symbol.ohos_trash'),
            fontColorResource: [$r('sys.color.ohos_id_color_primary')],
            accessibilityTxt: ResourceUtil.getStringByResource(MENU_NAME.deleteAll),
            clickCallback: () => {
              HiLog.warn(TAG, 'RECENT_DELETE click ')
              this.onClickCallback(ToolOperateType.CLEAR_FILES);
            }
          })
            .alignRules({
              left: { anchor: 'create_folder', align: HorizontalAlign.Start },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .id('clear_all')
            .enabled(this.isEnabledStatus())
            .opacity(this.getOpacityVal())
        }

        // 按XX排序，位于中间
        Button({ buttonStyle: ButtonStyleMode.TEXTUAL }) {
          Row() {
            Text(this.sortTypeResource)
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .draggable(false)
              .padding({
                left: $r('sys.float.padding_level2')
              })
              .fontColor([$r('sys.color.ohos_id_color_primary')])
              .width($r('app.float.common_size16'))
              .height($r('app.float.common_size24'))
              .fontSize($r('app.float.common_size16'))
          }
          .justifyContent(FlexAlign.Center)
          .padding({
            left: 10,
            right: 8,
            top: 6,
            bottom: 6
          })
        }
        .key('sortButton')
        .type(ButtonType.Capsule)
        .bindMenu(this.showTopMenu, this.sortMenu(), {
          onDisappear: () => {
            this.showTopMenu = false;
            const isFocused = focusControl.requestFocus('sortButton');
            HiLog.info(TAG, `sortButton requestFocus ${isFocused}`)
          },
          placement: Placement.Bottom
        })
        .onClick(() => {
          this.showTopMenu = true;
        })
        .padding($r('sys.float.padding_level3'))
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .accessibilityRole(AccessibilityRoleType.SELECT)
        .enabled(this.isEnabledStatus())

        // 列表/宫格，最右边
          SymbolIconButton({
            symbolResource: this.curFileViewType === ViewMode.GRID
              ? $r('sys.symbol.list_bullet')
              : $r('sys.symbol.square_grid_2x2'),
            fontColorResource: [$r('sys.color.ohos_id_color_primary')],
            accessibilityTxt: this.curFileViewType === ViewMode.GRID
              ? ResourceUtil.getStringByResource($r('app.string.list_view'))
              : ResourceUtil.getStringByResource($r('app.string.grid_view')),
            clickCallback: () => {
              this.onClickCallback(this.curFileViewType === ViewMode.GRID
                ? ToolOperateType.VIEW_CHANGE_LIST
                : ToolOperateType.VIEW_CHANGE_GRID);
              this.curFileViewType = this.curFileViewType === ViewMode.GRID ? ViewMode.LIST : ViewMode.GRID;
              // 无障碍播报
              AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility(
                getResourceString($r('app.string.list_grid_toggle'),
                  this.curFileViewType === ViewMode.GRID ? ResourceUtil.getStringByResource($r('app.string.grid_view'))
                    : ResourceUtil.getStringByResource($r('app.string.list_view'))));
              AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.LIST_OR_GRID_BUTTON);
            },
            compId: CompId.LIST_OR_GRID_BUTTON
          })
            .alignRules({
              right: { anchor: '__container__', align: HorizontalAlign.End },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .enabled(this.isEnabledStatus())
            .opacity(this.getOpacityVal())
      }
      .size({ width: '100%', height: $r('app.float.common_size48') })
      .padding({ left: $r('app.float.common_size8'), right: $r('app.float.common_size8') })
    }
  }

  private initSortMenu(): void {
    HiLog.info(TAG, 'sort init ' + this.order + ' isDesc: ' + this.isDesc);
    this.sortMenuArray = [];
    this.sortTypeResource = sortMap.get(this.order) ?? $r('app.string.sort_by_name');
    this.sortMenuArray.push(new TopMenuItem(undefined, () => {
      this.sortChange(SortOrder.NAME);
    },
      MENU_NAME.name, SortOrder.NAME, TopMenuDivider.TYPE_TWO));
    this.sortMenuArray.push(new TopMenuItem(undefined, () => {
      this.sortChange(SortOrder.TYPE);
    },
      MENU_NAME.orderType, SortOrder.TYPE, TopMenuDivider.TYPE_TWO));
    this.sortMenuArray.push(new TopMenuItem(undefined, () => {
      this.sortChange(SortOrder.TIME);
    },
      MENU_NAME.orderTime, SortOrder.TIME, TopMenuDivider.TYPE_TWO));
    this.sortMenuArray.push(new TopMenuItem(undefined, () => {
      this.sortChange(SortOrder.SIZE);
    },
      MENU_NAME.orderSize, SortOrder.SIZE, TopMenuDivider.TYPE_NONE));
  }

  private sortChange(order: string): void {
    HiLog.warn(TAG, `sort init order ${order}, old order: ${this.order}`);
    switch (order) {
      case SortOrder.DEFAULT:
        this.sortTypeResource = $r('app.string.sort_by_default');
        break;
      case SortOrder.NAME:
        this.sortTypeResource = $r('app.string.sort_by_name');
        break;
      case SortOrder.TIME:
        this.sortTypeResource = $r('app.string.sort_by_time');
        break;
      case SortOrder.SIZE:
        this.sortTypeResource = $r('app.string.sort_by_size');
        break;
      case SortOrder.TYPE:
        this.sortTypeResource = $r('app.string.sort_by_type');
        break;
      default:
        this.sortTypeResource = $r('app.string.sort_by_name');
    }
    if (this.order === order) {
      this.isDesc = !this.isDesc;
    } else {
      this.order = order;
    }
    // 排序类型改变之后关闭排序菜单
    this.showTopMenu = false;
  }

  @Builder
  sortMenu() {
    TopMenu({
      topMenu: $sortMenuArray,
      fileCount: 0,
      hideMenu: () => {
        this.showTopMenu = false;
      }
    })
  }

  // 判断按钮是否可用
  private isEnabledStatus(): boolean {
    return (this.userState !== UserState.MULTI_START || this.isPickerFlag) && !this.isShowLoading;
  }

  // 获取按钮的透明度，不可用时透明度需要做配置
  private getOpacityVal(): Resource {
    return this.isEnabledStatus() ? $r('app.float.common_opacity10') : $r('app.float.common_opacity5');
  }
}