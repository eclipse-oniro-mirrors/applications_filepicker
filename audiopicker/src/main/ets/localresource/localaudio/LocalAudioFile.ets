/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

export class LocalAudioFile {
  // 文件uri
  uri: string = ''
  // 名称
  name: string = ''
  // 歌手
  artist: string = ''
  // 专辑
  album: string = ''

  constructor(uri: string, name: string, artist: string, album: string){
    this.uri = uri
    this.name = name
    this.artist = artist
    this.album = album
  }
}