/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
 */

/**
 * [系统全局globalThis挂载的对象类型定义]
 *
 * @author
 * @version [V1.0.0.0, 2022/7/20]
 * @since V1.0.0.0
 */
import window from '@ohos.window'
import display from '@ohos.display'
import deviceInfo from '@ohos.deviceInfo'
import type context from '@ohos.app.ability.common'
import i18n from '@ohos.i18n'
import pointer from '@ohos.multimodalInput.pointer';
import type { BusinessError } from '@ohos.base'

import { Logger } from '../../util/HiLogger'
import { appStorageKeys, setOrCreateAppStorage } from '../AppStorageHelper'
import { createOrGet, globalKeys } from '../GlobalThisHelper'
import { Util } from '../../util/Util'

const logger: Logger = new Logger("GlobalModel")
// PC的头部间距，16 / 160
const PC_TOP_PADDING: number = 0.1
// 分屏比例
const SPLIT_RATIO_MINI = 5 / 12
const SPLIT_RATIO_MAX = 7 / 12
// 白色字符串
const WHITE: string = "#ffffffff"
// 黑色字符串
const BLACK: string = "#ff000000"
// 透明
const TRANS: string = "#00ffffff"

/**
 * 窗口对象
 */
export class AppScreen {
  // abilityContext
  context: context.UIAbilityContext
  // stage模型的窗口对象
  windowStage: window.WindowStage
  // 屏幕宽度
  width: number = 0
  // 屏幕高度
  height: number = 0
  // 窗口x坐标
  windowPosX: number = 0
  // 窗口y坐标
  windowPosY: number = 0
  // 窗口宽度
  windowWidth: number = 0
  // 窗口高度
  windowHeight: number = 0
  // 状态栏高度
  topHeight: number = 0
  // 导航栏高度
  bottomHeight: number = 0
  // 屏幕密度类型，用来计算lpx真实物理大小
  densityType: DensityTypes = DensityTypes.SM
  // 窗口配置变化监听
  configChangeListener: Array<(densityType: DensityTypes) => void> = []
  // 接收窗口变化后一系列配置完成后的promise
  lastWindowSizeResult: Promise<boolean> = Promise.resolve(true)
  // 横竖屏模式设定
  orientationSetting: window.Orientation = window.Orientation?.AUTO_ROTATION_LANDSCAPE_RESTRICTED
  // 当前是横屏1还是竖屏0
  orientation: number = 0
  // 是否已经设置过沉浸式
  isImmersiveSet: boolean = false
  // 应用启动后是否设置过densityType
  isDensityTypeSet: boolean = false
  // DPI mate40pro 560
  densityDPI: number = 0
  // 是否全屏
  isFullScreen: boolean = false
  // 沉浸式，可以显示状态栏文字
  isLayoutFullScreen: boolean = false
  // 沉浸式，不显示状态栏文字
  isFullScreenWindow: boolean = false
  // 天枢wgr是否分屏， 高度为设备高度，且宽度小于设备宽度
  isPCMultiWindow: boolean = false
  // 状态栏背景是否是深色
  isTopBgDark: boolean = false
  // 状态栏背景颜色
  statusBarBgColor: string = ""
  // 导航栏背景是否是深色
  isBottomBgDark: boolean = false
  // 屏幕是否常亮
  isKeepScreenOn: boolean = false
  // 判断当前设备是否可折叠
  isFoldScreen: boolean = false
  // 获取当前屏幕折叠状态  展开态: 1 折叠态: 2 半折态: 3
  displayStatus: number = 1
  // 获取当前屏幕显示模式0:折叠状态未知1:折叠状态为完全展开2:折叠状态为折叠3:折叠状态为半折叠。半折叠指完全展开和折叠之间的状态。
  displayMode: number = 0
  // 分屏比例
  appSplitRatio: AppSplitRatios = AppSplitRatios.NO
  // 当前窗口模式
  windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED
  // 应用信息
  app: MusicApp

  // 构造函数
  constructor(context: context.UIAbilityContext, windowStage: window.WindowStage) {
    logger.info('new Screen')
    this.context = context
    this.windowStage = windowStage
    this.app = createOrGet(MusicApp, globalKeys.app)
    this.init()
  }

  /**
   * 初始化
   */
  async init(): Promise<void> {
    this.enterImmersion()
    this.getDisplayStatus()
    this.bindWindowSizeListener()
    this.bindFoldStatusChange()
    this.bindFoldDisplayModeChange()
    this.setOrientationSetting()
    this.lastWindowSizeResult = this.windowResize()
    this.bindWindowEventListener()
  }

  /**
   * 监听应用窗口焦点变化
   */
  bindWindowEventListener(): void {
    window.getLastWindow(this.context).then((windowClass) => {
      logger.info('Succeeded in obtaining the top window. Data: ' + windowClass);
      if (!windowClass) {
        return
      }
      try {
        windowClass.on('windowEvent', (value) => {
          if (value === window.WindowEventType.WINDOW_ACTIVE) {
            logger.info('Window event happened. Event:' + value);
            this.app?.setActiveNo()
          }
        });
      } catch (err) {
        logger.error('Failed to register callback. Cause: ' + JSON.stringify(err));
      }
    }).catch((err: BusinessError) => {
      logger.error('Failed to obtain the top window. Cause: ' + JSON.stringify(err));
    });
  }

  getDisplayStatus(): void {
    this.isFoldScreen = display.isFoldable();

    this.displayStatus = display.getFoldStatus();

    this.displayMode = display.getFoldDisplayMode();
  }

  setOrientationSetting(): void {
    let orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED
    let globalDeviceInfo: DeviceInfo = createOrGet(DeviceInfo, globalKeys.deviceInfo)
    let isPhone: boolean = globalDeviceInfo.deviceType === DeviceTypes.PHONE
    logger.info('this.isFoldScreen' + this.isFoldScreen + 'this.displayMode' + this.displayMode)
    if (this.isFoldScreen) {
      if (this.displayMode === 1) {
        logger.info('this.isFoldScreen' + this.isFoldScreen + 'this.displayMode' + this.displayMode)
        orientation = window.Orientation.AUTO_ROTATION_RESTRICTED
      } else if (this.displayMode === 2) {
        logger.info('this.isFoldScreen' + this.isFoldScreen + 'this.displayMode' + this.displayMode)
        orientation = window.Orientation.PORTRAIT
      } else if (this.displayMode === 3 || this.displayMode === 0) {
        return
      }
    } else if (isPhone) {
      // 手机横屏MD修改判断设备类型
      orientation = window.Orientation.PORTRAIT
    } else {
      orientation = window.Orientation.AUTO_ROTATION_RESTRICTED
    }
    this.setOrientation(orientation)
  }

  /**
   * 销毁
   */
  destroy(): void {
    this.unbindWindowSizeListener()
    this.unbindFoldDisplayModeChange()
    this.unbindFoldStatusChange()
    this.unbindWindowEventListener()
  }

  /**
   * 取消监听应用窗口焦点变化
   */
  unbindWindowEventListener(): void {
    // todo: onDestroy的时候窗口已经销毁了，目前没有合适的元能力生命周期用于解注册监听,窗口已知的一个现象，后续解决再放开
    // try {
    //   windowClass.off('windowEvent');
    // } catch (exception) {
    //   logger.error('Failed to unregister callback. Cause: ' + JSON.stringify(exception));
    //  }
  }

  /**
   * 绑定窗口变化监听
   */
  async bindWindowSizeListener(): Promise<void> {
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return
    }
    // 绑定窗口变化监听
    w.on('windowSizeChange', (data: window.Size) => {
      logger.info('windowSizeChange' + JSON.stringify(data))
      this.windowResizeHapenned(data)
    })
    w.on('avoidAreaChange', (data) => {
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        logger.info('avoidAreaChange' + JSON.stringify(data.area))
        let isPC = isWideService()
        this.topHeight = data.area.topRect.height

        this.bottomHeight = data.area.bottomRect.height
        if (isPC && this.topHeight === 0) {
          this.topHeight = PC_TOP_PADDING * this.densityDPI
        }
        setOrCreateAppStorage<number>(appStorageKeys.statusBarHeight, this.topHeight)
        setOrCreateAppStorage<number>(appStorageKeys.navigatorBarHeight, this.bottomHeight)

      }
    })
    // 绑定窗口模式变化监听
    w.on('windowStatusChange', (windowStatusChange: window.WindowStatusType) => {
      logger.info('windowStatusChange: ' + JSON.stringify(windowStatusChange))
      this.windowStatusType = windowStatusChange
      if (windowStatusChange === window.WindowStatusType.MINIMIZE) {
        return
      }
      if (windowStatusChange === window.WindowStatusType.SPLIT_SCREEN) {
        this.setSplitRatio()
      } else {
        this.setAppSplitRatio(AppSplitRatios.NO)
      }
    })
  }

  /**
   * 注销窗口变化监听
   */
  async unbindWindowSizeListener(): Promise<void> {
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return
    }
    // 和zhengjiangliang OFF不传callback整体注销
    await w.off('windowSizeChange')
    await w.off('avoidAreaChange')
    await w.off('windowStatusChange')
  }

  /**
   * 绑定折叠屏折叠状态变化监听
   */
  bindFoldStatusChange(): void {

    try {
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        this.displayStatus = foldStatus;
        logger.info('displayMode' + foldStatus)
      });
    } catch (exception) {
      logger.error('Failed code' + JSON.stringify(exception));
    }
  }

  /**
   * 注销绑定折叠屏折叠状态变化监听
   */
  unbindFoldStatusChange(): void {
    display.off('foldStatusChange')
  }

  /**
   * 绑定折叠屏折叠模式变化监听
   */
  bindFoldDisplayModeChange(): void {
    try {
      display.on('foldDisplayModeChange', (foldDisplayMode: display.FoldDisplayMode) => {
        logger.info('displayMode' + foldDisplayMode + this.displayMode + this.orientationSetting)
        this.displayMode = foldDisplayMode;
        this.setOrientationSetting()
      });
    } catch (exception) {
      logger.error('Failed code' + JSON.stringify(exception));
    }
  }

  unbindFoldDisplayModeChange(): void {
    display.off('foldDisplayModeChange')
  }

  /**
   * 设置全局ability上下文
   */
  setContext(context: context.UIAbilityContext): void {
    this.context = context
  }

  /**
   * 获取屏幕大小
   */
  async getScreenSize(): Promise<boolean> {
    logger.info('windows getScreenSize')
    let p1 = display.getDefaultDisplay().then((disp) => {
      logger.info('getDefaultDisplay:' + JSON.stringify(disp));
      this.width = disp.width
      this.height = disp.height
      this.densityDPI = disp.densityDPI
    })
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return new Promise((resolve) => {
        p1.then(() => {
          resolve(true)
        })
      })
    }
    let p2 = w.getProperties().then((prop: window.WindowProperties) => {
      logger.info('getProperties:' + JSON.stringify(prop));
      this.windowWidth = prop.windowRect.width
      this.windowHeight = prop.windowRect.height
      this.windowPosX = prop.windowRect.left
      this.windowPosY = prop.windowRect.top
      this.isLayoutFullScreen = prop.isLayoutFullScreen || false
      this.isFullScreenWindow = prop.isFullScreen
    })

    let isPC = isWideService()
    return isPC ? new Promise((resolve) => {
      Promise.all([p1, p2]).then(() => {
        // PC模式下，有可能设置为手机全屏，此时模式如下判断，需要设置窗口高度减去topHeight
        if (!this.isFullScreen && this.windowWidth === this.width && this.windowHeight === this.height && this.isLayoutFullScreen && !this.isFullScreenWindow) {
          logger.info('pc topHeight:' + this.topHeight);
          this.windowHeight -= this.topHeight
          logger.info('pc windowHeight:' + this.windowHeight);
        }
        this.isPCMultiWindow = this.windowHeight === this.height && this.windowWidth !== this.width
        this.topHeight = PC_TOP_PADDING * this.densityDPI
        setOrCreateAppStorage<number>(appStorageKeys.statusBarHeight, this.topHeight)
        if (!this.isLayoutFullScreen && !this.isPCMultiWindow) {
          // 天枢窗口非全屏模式非分屏模式，顶部38vp，底部和左右各5vp
          this.windowWidth = this.windowWidth - 10 * this.densityDPI / 160
          this.windowHeight = this.windowHeight - 43 * this.densityDPI / 160
        }
        this.setSplitRatio()
        resolve(true)
      })
    }) : Promise.all([p1, p2]).then(() => {
      this.setSplitRatio()
      return true
    }).catch(() => {
      return false
    })
  }

  /**
   * 设置全屏和状态栏颜色
   */
  async enterImmersion(): Promise<void> {
    logger.info('windows enterImmersion')
    // 手机默认设置全屏，平板PC默认设置不全屏。 如果全屏模式发生切换，则置设置沉浸模式标记位为否，重新进入设置
    // 除PC之外，其他默认设置全屏
    let isFullScreen = !isWideService()
    this.isImmersiveSet && (this.isImmersiveSet = isFullScreen === this.isFullScreen)
    this.isFullScreen = isFullScreen
    if (this.isImmersiveSet) {
      return
    }
    this.isImmersiveSet = true
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return
    }
    if (this.isFullScreen) {
      logger.info('this.isFullScreen' + this.isFullScreen)
      // await w.setFullScreen(this.isFullScreen)
      await w.setWindowLayoutFullScreen(this.isFullScreen)
    }
    // await w.setSystemBarEnable(["status", "navigation"])
    this.setSystemBarColor(this.isTopBgDark, this.isBottomBgDark, w)
    logger.info('windows enterImmersion finish')
  }

  /**
   * 设置横竖屏模式
   *
   * @param isTopBgDark 顶部背景是否深色
   * @param isBottomBgDark 底部背景是否深色
   * @param w topWindow
   */
  setSystemBarColor(isTopBgDark: boolean = false, isBottomBgDark: boolean = false, w?: window.Window,): void {
    this.isTopBgDark = isTopBgDark
    this.setSystemBarColorWithColor(isTopBgDark ? WHITE : BLACK, isBottomBgDark, w)
  }

  /**
   * 设置系统bar颜色
   *
   * @param isTopBgDark 顶部背景是否深色
   * @param isBottomBgDark 底部背景是否深色
   * @param w topWindow
   */
  setSystemBarColorWithColor(statusBarBgColor: string, isBottomBgDark: boolean = false, w?: window.Window): void {
    if (Util.isEmpty(statusBarBgColor)) {
      logger.error("setSystemBarColorWithColor :: statusBarBgColor is Empty")
      return
    }

    if (statusBarBgColor === this.statusBarBgColor && isBottomBgDark === this.isBottomBgDark) {
      return
    }
    if (!w) {
      try {
        w = this.windowStage.getMainWindowSync()
      } catch (error) {
        logger.info(`setSystemStatusBarColor, getMainWindowSync error: ${JSON.stringify(error, [`code`, `message`])}`);
      }
      if (!w) {
        return
      }
    }

    try {
      this.statusBarBgColor = statusBarBgColor
      this.isBottomBgDark = isBottomBgDark
      w.setWindowSystemBarProperties({
        navigationBarColor: TRANS,
        statusBarColor: TRANS,
        navigationBarContentColor: isBottomBgDark ? WHITE : BLACK,
        // todo - 如果是深色模式，只需此处逻辑改为 statusBarContentColor: isDark ? ColorUtil.WHITE : statusBarBgColor
        statusBarContentColor: statusBarBgColor
      }, null)
    } catch (error) {
      logger.error(`setSystemBarColor, setWindowSystemBarProperties error: ${JSON.stringify(error, [`code`, `message`])}`);
    }
  }

  /**
   * 设置横竖屏模式
   *
   * @param orientation 横竖屏模式
   */
  async setOrientation(orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED): Promise<void> {
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return
    }
    logger.info('this.densityType' + this.densityType + 'this.isFoldScreen' + this.isFoldScreen + 'this.displayMode' + this.displayMode)
    logger.info('windowResize densityType' + this.orientationSetting + 'orientation' + orientation)
    if (this.orientationSetting === orientation) {
      return
    }
    this.orientationSetting = orientation
    logger.info('windowResize densityType350' + this.orientationSetting + 'orientation' + orientation)
    await w.setPreferredOrientation(orientation)
  }

  /**
   * 获取状态栏和导航栏高度
   */
  async getAvoidArea(): Promise<void> {
    logger.info('windows getAvoidArea')
    let w = await this.windowStage.getMainWindow()
    if (!w) {
      return
    }
    let area = await w.getAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    logger.info('windows getAvoidArea' + JSON.stringify(area))
    let isPC = isWideService()
    // PC模式下，如果头部没有空隙，留一定空隙
    if (isPC && area.topRect.height === 0) {
      this.topHeight = PC_TOP_PADDING * this.densityDPI
      // fix systemUI bug 每次下拉系统通知栏，状态栏高度会为0 需要屏蔽掉
    } else if (area.topRect.height !== 0) {
      this.topHeight = area.topRect.height
    }
    this.bottomHeight = area?.bottomRect?.height || 0
    logger.info('windows getAvoidArea finish')
  }

  /**
   * 窗口变化发生
   *
   * @param data 窗口数据
   */
  windowResizeHapenned(data: window.Size): void {
    logger.info('Succeeded in enabling the listener for window size changes. Data: ' + JSON.stringify(data));
    this.lastWindowSizeResult = this.windowResize()
  }

  /**
   * 处理窗口变化修改成员变量属性值
   *
   * @return Promise<boolean> 窗口变化结果，成功失败
   */
  windowResize(): Promise<boolean> {
    return new Promise(async (resolve, reject) => {
      // todo 当前设置全屏后会触发resize，然后又走到这个方法，所以设置全屏和获取屏幕属性方法的时序不需要控制。反正resize之后还有重新获取屏幕属性
      let p2 = this.getAvoidArea()
      let p3 = this.getScreenSize()
      Promise.all([p2, p3]).then(() => {
        this.windowResizeDetail()
        resolve(true)
      }).catch(() => {
        resolve(false)
      })
    })
  }

  /**
   * 处理窗口变化修改成员变量属性值具体方法
   */
  windowResizeDetail: () => void = () => {
    if (this.densityDPI === 0) {
      logger.info('densityDPI zero')
      return
    }
    // 说明计算公式pixels = dips * (density / 160)
    let vpWidth = this.windowWidth / (this.densityDPI / 160)
    let densityType: DensityTypes = DensityTypes.SM
    if (vpWidth < 320) {
      densityType = DensityTypes.XS
    } else if (vpWidth < 600) {
      densityType = DensityTypes.SM
    } else if (vpWidth < 840) {
      densityType = DensityTypes.MD
    } else {
      densityType = DensityTypes.LG
    }
    logger.info('windowResize densityType' + densityType + 'vpWidth' + vpWidth)
    this.setDensityType(densityType)
    this.setOrientationSetting()
  }
  /**
   * 计算分屏模式下比例
   *
   * @param listener 窗口变化监听器
   */
  setSplitRatio: () => void = (): void => {
    let appSplitRatio: AppSplitRatios
    if (this.windowStatusType !== window.WindowStatusType.SPLIT_SCREEN) {
      // 应用宽高与窗口宽高未分屏
      logger.info('windowResize appSplitRatio none')
      appSplitRatio = AppSplitRatios.NO
      return
    } else if (this.windowWidth === this.width) {
      // 应用宽度 = 窗口宽度：上下分屏，通过计算 应用高度与窗口高度比值 判断 音乐分屏比例
      if (this.windowHeight <= this.height * SPLIT_RATIO_MINI) {
        appSplitRatio = AppSplitRatios.PORTRAIT_S
      } else if (this.windowHeight > this.height * SPLIT_RATIO_MAX) {
        appSplitRatio = AppSplitRatios.PORTRAIT_L
      } else {
        appSplitRatio = AppSplitRatios.PORTRAIT_M
      }
    } else if (this.windowHeight === this.height) {
      // 应用高度 = 窗口高度：左右分屏，通过计算 应用宽度与窗口宽度比值 判断 音乐分屏比例
      if (this.windowWidth <= this.width * SPLIT_RATIO_MINI) {
        appSplitRatio = AppSplitRatios.LANDSCAPE_S
      } else if (this.windowWidth > this.width * SPLIT_RATIO_MAX) {
        appSplitRatio = AppSplitRatios.LANDSCAPE_L
      } else {
        appSplitRatio = AppSplitRatios.LANDSCAPE_M
      }
    } else {
      appSplitRatio = AppSplitRatios.NO
    }
    logger.info(`windowResize appSplitRatio ${appSplitRatio} ${this.windowWidth} ${this.width} ${this.windowHeight} ${this.height}`)
    this.setAppSplitRatio(appSplitRatio)
  }
  /**
   * 设置屏幕密度类型
   *
   * @param type 屏幕密度类型
   */
  setDensityType: (type: DensityTypes) => void = (type: DensityTypes): void => {
    this.densityType = type
    let windowArea: WindowArea = { windowWidth: this.windowWidth, windowHeight: this.windowHeight }
    setOrCreateAppStorage<DensityTypes>(appStorageKeys.densityType, type)
    setOrCreateAppStorage<number>(appStorageKeys.screenWidth, this.width)
    setOrCreateAppStorage<number>(appStorageKeys.screenHeight, this.height)
    setOrCreateAppStorage<number>(appStorageKeys.windowWidth, this.windowWidth)
    setOrCreateAppStorage<number>(appStorageKeys.windowHeight, this.windowHeight)
    // 保证横竖屏切换两个同时更新
    setOrCreateAppStorage<WindowArea>(appStorageKeys.windowArea, windowArea)
    setOrCreateAppStorage<number>(appStorageKeys.statusBarHeight, this.topHeight)
    setOrCreateAppStorage<number>(appStorageKeys.navigatorBarHeight, this.bottomHeight)
    if (this.configChangeListener.length > 0) {
      this.configChangeListener.forEach((listener) => {
        try {
          listener(type)
        } catch (e) {
          logger.info('setDensityType forEach error = ' + e);
        }
      })
    }
  }
  /**
   * 设置分屏比例
   *
   * @param ratio 分屏比例
   */
  setAppSplitRatio: (ratio: AppSplitRatios) => void = (ratio: AppSplitRatios): void => {
    this.appSplitRatio = ratio
    setOrCreateAppStorage<AppSplitRatios>(appStorageKeys.appSplitRatio, ratio)
  }

  /**
   * 设置鼠标形状
   * @param pointerStyle 鼠标形状
   */
  async setPointerStyle(pointerTypes: pointer.PointerStyle): Promise<void> {
    let w = await this.windowStage.getMainWindow()
    w.getProperties().then((prop: window.WindowProperties) => {
      let windowId = prop.id;
      if (windowId < 0) {
        logger.info(`Invalid windowId`);
        return;
      }
      try {
        pointer.setPointerStyle(windowId, pointerTypes).then(() => {
          logger.info(`Set pointer style success`);
        });
      } catch (error) {
        logger.info(`Set pointer style failed, error: ${JSON.stringify(error, [`code`, `message`])}`);
      }
    })
  }

  /**
   * 设置/取消屏幕常亮
   * @param screenOn
   */
  async setIsKeepScreenOn(screenOn: boolean): Promise<void> {
    logger.info('setIsKeepScreenOn ' + screenOn + ' this.isKeepScreenOn ' + this.isKeepScreenOn)
    if (screenOn === this.isKeepScreenOn) {
      return
    }

    let w = await this.windowStage.getMainWindow()
    if (!w) {
      logger.info('setIsKeepScreenOn return')
      return
    }
    try {
      w.setWindowKeepScreenOn(screenOn, (err) => {
        if (err.code) {
          logger.error('Failed to set the screen to be always on. Cause: ' + JSON.stringify(err));
          return;
        }
        this.isKeepScreenOn = screenOn
        logger.info('Succeeded in setting the screen to be always on.' + screenOn);
      });
    } catch (exception) {
      logger.error('Error to set the screen to be always on. Cause: ' + JSON.stringify(exception));
    }
  }
}

export function isWideService(): boolean {
  const globalDeviceInfo: DeviceInfo = createOrGet(DeviceInfo, globalKeys.deviceInfo)
  // return globalDeviceInfo.deviceType === DeviceTypes.TABLET || globalDeviceInfo.deviceType === DeviceTypes.PC
  return globalDeviceInfo.deviceType === DeviceTypes.PC
}

/**
 * 设备类型
 */
export enum DeviceTypes {
  PHONE = 0,
  TABLET = 1,
  PC = 2
}


/**
 * 渠道类型
 */
export enum EnvironmentType {
  // 联调环境
  DEV = 0,
  // 镜像环境
  MIRROR = 1,
  // 现网环境
  SECURITY = 3
}

/**
 * 屏幕密度类型
 */
export enum DensityTypes {
  // 手表
  XS = 0,
  // 手机竖屏和折叠屏不展开
  SM = 1,
  // 折叠屏展开和pad竖屏
  MD = 2,
  // pad横屏
  LG = 3
}

/**
 * 分屏模式下音乐与其他应用所占屏幕比例
 */
export enum AppSplitRatios {
  // 不分屏
  NO = 0,
  // 上下分屏 音乐与其他应用屏幕占比 <= 1:2
  PORTRAIT_S = 1,
  // 上下分屏 音乐与其他应用屏幕占比 1:2 ~ 2:1
  PORTRAIT_M = 2,
  // 上下分屏 音乐与其他应用屏幕占比 >= 2:1
  PORTRAIT_L = 3,
  // 左右分屏 音乐与其他应用屏幕占比 <= 1:2
  LANDSCAPE_S = 4,
  // 左右分屏 音乐与其他应用屏幕占比 1:2 ~ 2:1
  LANDSCAPE_M = 5,
  // 左右分屏 音乐与其他应用屏幕占比 >= 2:1
  LANDSCAPE_L = 6,
}


/**
 * 设备信息
 */
export class DeviceInfo {
  // 设备类型
  deviceType: number = DeviceTypes.PHONE
  /**
   * Obtains the product model represented by a string.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  productModel: string
  /**
   * Obtains the OS version represented by a string.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  osFullName: string
  /**
   * Obtains the SDK API version number.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  sdkApiVersion: number
  /**
   * Obtains the device udid.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 7
   */
  udid: string
  /**
   * Obtains the device manufacturer represented by a string.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  manufacture: string
  /**
   * Obtains the device brand represented by a string.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  brand: string
  /**
   * User-Agent
   *
   * model=FFG-AL00,brand=HUAWEI,rom=EmotionUI_12.0.1,emui=EmotionUI_12.0.1,os=11,apilevel=30,manufacturer=HUAWEI,useBrandCust=0,extChannel=,cpucore=8,memory=8.0G,srceenHeight=2529,screenWidth=1200,harmonyApiLevel=6,huaweiOsBrand=harmony
   */
  ua: string = ''
  /**
   * Obtains the major (M) version number, which increases with any updates to the overall architecture.
   * <p>The M version number monotonically increases from 1 to 99.
   *
   * @syscap SystemCapability.Startup.SystemInfo
   * @since 6
   */
  majorVersion: number
  // 系统语言
  lang: string = MusicApp.DEFAULT_LANG
  /**
   * 获取CPU的核数 todo
   *
   * @return CPU的核数，异常情况下CPU核数为-1
   */
  cpucores: string = '8'
  memory: string = '8.0G'

  constructor() {
    //     * which can be {@code phone} (or {@code default} for phones), {@code wearable}, {@code liteWearable},
    //     * {@code tablet}, {@code tv}, {@code car}, or {@code smartVision}.
    switch (deviceInfo.deviceType) {
      case 'phone':
        this.deviceType = DeviceTypes.PHONE
        break;
      case 'default':
        this.deviceType = DeviceTypes.PHONE
        break;
      case 'tablet':
        this.deviceType = DeviceTypes.TABLET
        break;
      case '2in1':
        this.deviceType = DeviceTypes.PC
        break;
      case 'pc':
        this.deviceType = DeviceTypes.PC
        break;
      default:
        this.deviceType = DeviceTypes.PHONE
        break;
    }
    this.osFullName = deviceInfo.osFullName
    this.sdkApiVersion = deviceInfo.sdkApiVersion
    // this.udid = deviceInfo.udid 权限不满足获取不到
    this.udid = ''
    this.manufacture = deviceInfo.manufacture
    this.majorVersion = deviceInfo.majorVersion
    this.brand = (deviceInfo.brand).toUpperCase()
    this.productModel = deviceInfo.productModel
    display.getDefaultDisplay().then((disp) => {
      logger.info('getDefaultDisplay in device:' + JSON.stringify(disp));
      this.ua = `model=${this.productModel},brand=${this.brand},rom=${this.osFullName},emui=${this.osFullName},os=${this.majorVersion},apilevel=${this.sdkApiVersion},manufacturer=${this.brand},useBrandCust=0,extChannel=,cpucore=8,memory=8.0G,srceenHeight=${disp.width},screenWidth=${disp.height},harmonyApiLevel=${this.sdkApiVersion},huaweiOsBrand=harmony`
      logger.debug('deviceType ua:' + this.ua)
    })
    // todo 需要确认udid是否可以在同意协议之前获取。
    logger.debug('deviceType: ' + deviceInfo.deviceType + ';osFullName: ' + deviceInfo.osFullName + ';sdkApiVersion: ' + deviceInfo.sdkApiVersion + ';udid: ' + (deviceInfo.udid !== undefined) + ';manufacture: ' + deviceInfo.manufacture + ';brand: ' + deviceInfo.brand + ';hardwareProfile:' + deviceInfo.hardwareProfile)
    this.getLang()
  }

  /**
   * 获取系统语言
   *
   * @return 语言是否发生切换
   */
  getLang(): boolean {
    let lang = i18n.getSystemLocale()
    let langRes = ''
    // en-Latn-US 去除Latn
    if (lang) {
      let langArray = lang.split('-')
      if (langArray.length === 3) {
        langRes = langArray[0] + '-' + langArray[2]
      } else {
        langRes = lang
      }
    } else {
      langRes = MusicApp.DEFAULT_LANG
    }
    let res = langRes !== this.lang
    this.lang = langRes
    // 语言发生变化时更新全局变量
    if (res) {
      setOrCreateAppStorage<string>(appStorageKeys.lang, this.lang)
    }
    logger.info("i18n getSystemLanguage: " + this.lang)
    return res
  }
}

/**
 * BEARER_CELLULAR    0    蜂窝网络。
 * BEARER_WIFI    1    Wi-Fi网络。
 * BEARER_ETHERNET    3    以太网网络。
 */
enum NetworkType {
  // 蜂窝网络
  BEARER_CELLULAR = 0,
  // Wi-Fi网络
  BEARER_WIFI = 1,
  // 以太网网络。
  BEARER_ETHERNET = 3
}

/**
 * 应用信息
 */
export class MusicApp {
  // 客户端traceId
  xClientTraceId: string
  static readonly DEFAULT_LANG: string = 'zh_CN'
  // abilityStage上下文
  abilityStageContext: context.AbilityStageContext | undefined = undefined
  // ability上下文
  abilityContext: context.UIAbilityContext | null = null
  // UIExtensionContext上下文
  UIExtensionContext: context.UIExtensionContext | null = null
  // 产品类型名称 phone、watch
  productName: string
  // 應用是否在前台
  active: boolean = true
  activeNo: number = 0
  activeChangeListeners: Array<(active: boolean) => void> = []

  constructor(productName: string = 'phone') {
    this.productName = productName
    this.xClientTraceId = Util.systemUUid()
    logger.info("Music app init productName:" + this.productName)
  }

  /**
   * 注册應用是否在前台
   * @param listener listener
   */
  addActiveChangeListener(listener: (active: boolean) => void): void {
    this.activeChangeListeners.push(listener)
  }

  /**
   * 取消注册應用是否在前台
   * @param listener listener
   */
  removeActiveChangeListener(listener: (active: boolean) => void): void {
    let idx = this.activeChangeListeners.findIndex((item) => {
      return item === listener
    })
    if (idx > -1) {
      this.activeChangeListeners.splice(idx, 1)
    }
  }

  /**
   * 修改應用是否在前台
   * @param active active
   */
  setActive(active: boolean): void {
    this.active = active
    if (this.activeChangeListeners.length) {
      this.activeChangeListeners.forEach((listener: (active: boolean) => void) => {
        listener(active)
      })
    }
  }

  /**
   * 修改重复退出回到应用次数
   * @param active active
   */
  setActiveNo(): void {
    this.activeNo++
    logger.info("activeNo " + this.activeNo)
  }
}

/**
 * 宽高同时更新
 */
export class WindowArea {
  windowWidth: number = 0
  windowHeight: number = 0
}

