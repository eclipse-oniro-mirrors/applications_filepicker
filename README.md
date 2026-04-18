# FileManager

## 简介

FileManager应用是OpenHarmony标准系统中预置的系统应用，为用户提供基础的文件管理功能，包括查看文件，查找文件，
快捷键，文管设置，整理文件。

### 项目架构


```
/applications/standard/filemanager
├─ products                         # 产品相关代码
│  └─ phone
│     └─ src
│        ├─ ohosTest                # OpenHarmony测试代码
│        ├─ main
│           ├─ ets
│              ├─ abilities         # 应用能力模块
│              ├─ application       # 应用程序相关代码
│              ├─ base              # 基础功能
│              ├─ common            # 通用功能
│              ├─ databases         # 数据库相关
│              ├─ pages             # 页面组件
│              ├─ taskpool          # 任务池相关
│           ├─ resources            # 资源文件
├─  common                   # 通用模块
├─  features                 # 功能模块
├─  script                   # 脚本文件
├─  sign                     # 签名相关
├─  signature                # 签名配置文件

```

