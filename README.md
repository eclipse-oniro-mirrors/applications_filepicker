# FilePicker<a name="ZH-CN_TOPIC_0000001103330836"></a>

-   [简介](#section11660541593)
    -   [架构图](#section125101832114213)

-   [目录](#section161941989596)
-   [相关仓](#section1371113476307)

## 简介<a name="section11660541593"></a>

FilePicker应用是OpenHarmony中预置的系统应用，为用户提供文件选择及保存功能。

### 架构图<a name="section125101832114213"></a>

![](figures\FP_FMS.png)

## 目录<a name="section161941989596"></a>

```
/applications/standard/filepicker
├── figures                     # 架构图目录
├── entry                       # 主entry模块目录
│   └── src
│       ├── main
│           ├── js              # js代码目录
│           ├── resources       # 资源配置文件存放目录
│           └── config.json     # 全局配置文件
├── product                     # 产品层模块目录
│   └── pad                     # pad模式模块目录
|       └── src
|           ├── main
|               ├── ets
│                   ├── MainAbility              # MainAbility代码目录
|                       ├── module               # 公共文件目录
|                       ├── pages                # 业务特性的View层目录
|                       ├── workers              # worker对于的js文件目录
│                   └── AbilityStage.ts
|               ├── resources   # 资源目录
|               └── config.json # 项目配置信息
│   └── phone                   # phone模式模块目录
||       └── src
|           ├── main
|               ├── ets
│                   ├── MainAbility              # MainAbility代码目录
|                       ├── module               # 公共文件目录
|                       ├── pages                # 业务特性的View层目录
|                       ├── workers              # worker对于的js文件目录
│                   └── AbilityStage.ts
|               ├── resources   # 资源目录
|               └── config.json # 项目配置信息
├── signature                   # 证书文件目录
├── LICENSE                     # 许可文件
```

## 相关仓<a name="section1371113476307"></a>

系统应用

**applications_filepicker**

