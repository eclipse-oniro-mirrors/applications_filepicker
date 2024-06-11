/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { image } from '@kit.ImageKit';

export class LocalAudioFile {
  // 文件uri
  uri: string = ''
  // 名称
  name: string = ''
  // 歌手
  artist: string = ''
  // 专辑
  album: string = ''
  // 显示名字
  displayName: string = ''
  // 缩略图
  getThumbnail?: image.PixelMap | Resource

  constructor(uri: string, name: string, artist: string, album: string, displayName: string, getThumbnail?: image.PixelMap | Resource) {
    this.uri = uri
    this.name = name
    this.artist = artist
    this.album = album
    this.displayName = displayName
    this.getThumbnail = getThumbnail
  }
}