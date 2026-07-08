# FileManager

## Description

FileManager is a pre-installed system application in the OpenHarmony standard system.
It provides users with basic file management functionalities, including viewing files,
searching for files, using keyboard shortcuts, configuring file management settings,
and organizing files.

### Core Features

1. **Storage Location Management**:Supports browsing and managing multiple storage locations, including My Phone (
   internal storage), external storage
   cards (USB drives, SD cards), Favorites folder, and Recently Deleted (Recycle Bin). Also supports File Manager
   Gallery for quickly browsing images and video files.

2. **File Picker**:Provides a file picker supporting single/multiple file selection. Also provides a path picker that
   allows custom save
   paths to save files to a specified directory.

3. **Viewing and Browsing**:Supports two display modes: grid view and list view, which can be freely switched; supports
   file sorting (by name, type, time, size); a live window displays file operation progress in real time; supports
   viewing file details (name, path, size, modification time, etc.).

4. **File Organization Operations**:Provides comprehensive file management operation capabilities: supports
   multi-selection, open, open with other apps,
   create new directory, rename, copy, paste, delete (move to Recently Deleted), permanently delete, restore (restore
   from Recently Deleted), move, favorite/unfavorite. Supports printing files, setting images as wallpapers, and setting
   audio files as ringtones. Supports emptying the Recycle Bin.

5. **Supplementary Features**:Supports file search within the current directory. Supports keyboard shortcut operations (
   copy/paste). Supports
   general settings to show hidden files (display files and folders starting with '.').

#### Software Architecture

![FileManager Architecture](./figures/filemanager-architecture.png)

##### Directory Layout

```
filemanager
├─ AppScope                              # Application-level config (app.json5, app resources)
├─ products                              # Product project (application entry)
│  └─ phone
│     └─ src
│        ├─ main
│        │  ├─ ets
│        │  │  ├─ abilities              # UIAbility
│        │  │  │  ├─ filemanager         # Main file manager ability
│        │  │  │  ├─ filepicker          # File picker UIExtAbility
│        │  │  │  ├─ ServiceExtAbility   # Background service ability
│        │  │  │  ├─ UIExtAbility.ets
│        │  │  │  └─ OpenMediaUIExtAbility.ets
│        │  │  ├─ application            # AbilityStage 
│        │  │  ├─ base                   
│        │  │  │  ├─ const / constants   # Constants
│        │  │  │  ├─ extension           # Extension models
│        │  │  │  ├─ manager             # Business managers (CopyCutManager / MenuActionHandler / ThumbnailCacheManager, etc.)
│        │  │  │  ├─ notification        # System notification wrappers (CopyCutNotificationUtil / NotificationUtil)
│        │  │  │  ├─ report              # Telemetry / reporting
│        │  │  │  └─ utils               # Utilities
│        │  │  ├─ databases              # Database models
│        │  │  ├─ pages                  # Pages (MainEntry / Settings / PathPicker / picker / preview / browser, etc.)
│        │  │  └─ taskpool               # TaskPool task wrappers
│        │  └─ resources                 # Strings, icons, media and other resources
│        └─ ohosTest                     # OpenHarmony unit / UI tests
├─ common                                # Shared HAR (HmCommon)
│  └─ src/main/ets
│     ├─ animation                       # Animation
│     ├─ config                          # Global configuration
│     ├─ const / constants               # Shared constants
│     ├─ data                            # Data models
│     ├─ database                        # Database primitives
│     ├─ dfx                             # Logging / telemetry (HiLog, etc.)
│     ├─ dragfile                        # Drag & drop
│     ├─ error                           # Error codes
│     ├─ favorite                        # Favorites
│     ├─ fileoperate                     # File operations (CRUD / move / copy)
│     ├─ filesort                        # Sorting
│     ├─ gallery / media                 # Multimedia
│     ├─ global                          # Global objects such as GlobalHolder
│     ├─ menu / model                    # Menu / shared models
│     ├─ pasteboard                      # Pasteboard
│     ├─ preference                      # Persistence
│     ├─ security                        # Encryption
│     ├─ share                           # Sharing
│     ├─ taskpool                        # Task pool
│     ├─ utils                           # Utilities
│     └─ worker / workermanager / workeroperate / workers   # Worker thread infrastructure (FileOperateWorker, etc.)
├─ features                              # Business feature HARs
│  ├─ addressBar                         # Address bar
│  ├─ bottomBar                          # Bottom action bar
│  ├─ customDialog                       # Custom dialogs (copy/move progress, confirmation, errors, etc.)
│  ├─ fileView                           # File list / grid view
│  ├─ sideBar                            # Side bar
│  └─ titleBar                           # Title bar
├─ open_source                           # Open-source notice
├─ sign / signature                      # Signing certificates and provisioning profiles
├─ build-profile.json5                   # Build & signing configuration
├─ oh-package.json5                      # Project-level dependencies
├─ LICENSE
└─ README.md / README_zh.md
```
