# Filepicker<a name="EN-US_TOPIC_0000001103330836"></a>

-   [Introduction](#section11660541593)
    -   [Architecture](#section125101832114213)

-   [Directory Structure](#section161941989596)
-   [Repositories Involved](#section1371113476307)

## Introduction<a name="section11660541593"></a>

Filepicker is a system app preinstalled in OpenHarmony. It provides users with file selection and saving functions.

### Architecture<a name="section125101832114213"></a>

![](figures\FP_FMS_EN.png)

## Directory Structure<a name="section161941989596"></a>

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

## Repositories Involved<a name="section1371113476307"></a>

System apps

**applications_filepicker**

