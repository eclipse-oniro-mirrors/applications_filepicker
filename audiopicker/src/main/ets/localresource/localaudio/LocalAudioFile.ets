/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { image } from '@kit.ImageKit';

export class LocalAudioFile {
  // 文件uri
  public uri: string = ''
  // 名称
  public name: string = ''
  // 歌手
  public artist: string = ''
  // 专辑
  public album: string = ''
  // 显示名字
  public displayName: string = ''
  // 缩略图
  public getThumbnail?: image.PixelMap | Resource

  constructor(uri: string, name: string, artist: string, album: string,
    displayName: string, getThumbnail?: image.PixelMap | Resource) {
    this.uri = uri
    this.name = name
    this.artist = artist
    this.album = album
    this.displayName = displayName
    this.getThumbnail = getThumbnail
  }
}