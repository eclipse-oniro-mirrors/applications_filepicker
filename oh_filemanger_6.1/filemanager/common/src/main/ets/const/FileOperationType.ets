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

export enum FileOperationType {
  CREATE_NEW,

  RENAME,

  COPY,

  MOVE,

  RECYCLE,

  RESTORE,

  DELETE,

  ADD_TAG
}

export function getOperatorResource(fileOperationType: FileOperationType): Resource {
  switch (fileOperationType) {
    case FileOperationType.CREATE_NEW:
      return $r('app.string.create_new');
    case FileOperationType.RENAME:
      return $r('app.string.rename');
    case FileOperationType.COPY:
      return $r('app.string.copy');
    case FileOperationType.MOVE:
      return $r('app.string.move');
    case FileOperationType.RECYCLE:
      return $r('app.string.recycle');
    case FileOperationType.RESTORE:
      return $r('app.string.restore');
    case FileOperationType.DELETE:
      return $r('app.string.delete');
    case FileOperationType.ADD_TAG:
      return $r('app.string.add_tag');
    default:
      return $r('app.string.blank');
  }
}
