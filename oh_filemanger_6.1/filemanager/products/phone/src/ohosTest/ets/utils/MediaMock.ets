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
import { image } from '@kit.ImageKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { rpc } from '@kit.IPCKit';

export class PixelMapMock implements image.PixelMap {
  public isEditable: boolean = false;

  readPixelsToBuffer(dst: ArrayBuffer): Promise<void>;
  readPixelsToBuffer(dst: ArrayBuffer, callback: AsyncCallback<void, void>): void;
  readPixelsToBuffer(dst: ArrayBuffer, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  readPixelsToBufferSync(dst: ArrayBuffer): void {
    throw new Error('Method not implemented.');
  }

  readPixels(area: image.PositionArea): Promise<void>;
  readPixels(area: image.PositionArea, callback: AsyncCallback<void, void>): void;
  readPixels(area: image.PositionArea, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  readPixelsSync(area: image.PositionArea): void {
    throw new Error('Method not implemented.');
  }

  writePixels(area: image.PositionArea): Promise<void>;
  writePixels(area: image.PositionArea, callback: AsyncCallback<void, void>): void;
  writePixels(area: image.PositionArea, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  writePixelsSync(area: image.PositionArea): void {
    throw new Error('Method not implemented.');
  }

  writeBufferToPixels(src: ArrayBuffer): Promise<void>;
  writeBufferToPixels(src: ArrayBuffer, callback: AsyncCallback<void, void>): void;
  writeBufferToPixels(src: ArrayBuffer, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  writeBufferToPixelsSync(src: ArrayBuffer): void {
    throw new Error('Method not implemented.');
  }

  toSdr(): Promise<void> {
    throw new Error('Method not implemented.');
  }

  getImageInfo(): Promise<image.ImageInfo>;
  getImageInfo(callback: AsyncCallback<image.ImageInfo, void>): void;
  getImageInfo(callback?: AsyncCallback<image.ImageInfo, void>): void | Promise<image.ImageInfo> {
    throw new Error('Method not implemented.');
  }

  getImageInfoSync(): image.ImageInfo {
    throw new Error('Method not implemented.');
  }

  getBytesNumberPerRow(): number {
    throw new Error('Method not implemented.');
  }

  getPixelBytesNumber(): number {
    throw new Error('Method not implemented.');
  }

  getDensity(): number {
    throw new Error('Method not implemented.');
  }

  opacity(rate: number, callback: AsyncCallback<void, void>): void;
  opacity(rate: number): Promise<void>;
  opacity(rate: number, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  opacitySync(rate: number): void {
    throw new Error('Method not implemented.');
  }

  createAlphaPixelmap(): Promise<image.PixelMap>;
  createAlphaPixelmap(callback: AsyncCallback<image.PixelMap, void>): void;
  createAlphaPixelmap(callback?: AsyncCallback<PixelMap, void>): void | Promise<image.PixelMap> {
    throw new Error('Method not implemented.');
  }

  createAlphaPixelmapSync(): image.PixelMap {
    throw new Error('Method not implemented.');
  }

  scale(x: number, y: number, callback: AsyncCallback<void, void>): void;
  scale(x: number, y: number): Promise<void>;
  scale(x: number, y: number, level?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  scaleSync(x: number, y: number): void;
  scaleSync(x: number, y: number, level: image.AntiAliasingLevel): void;
  scaleSync(x: number, y: number, level?: image.AntiAliasingLevel): void {
    throw new Error('Method not implemented.');
  }

  createScaledPixelMap(x: number, y: number, level?: image.AntiAliasingLevel | undefined): Promise<image.PixelMap> {
    throw new Error('Method not implemented.');
  }

  createScaledPixelMapSync(x: number, y: number, level?: image.AntiAliasingLevel | undefined): image.PixelMap {
    throw new Error('Method not implemented.');
  }

  translate(x: number, y: number, callback: AsyncCallback<void, void>): void;
  translate(x: number, y: number): Promise<void>;
  translate(x: number, y: number, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  translateSync(x: number, y: number): void {
    throw new Error('Method not implemented.');
  }

  rotate(angle: number, callback: AsyncCallback<void, void>): void;
  rotate(angle: number): Promise<void>;
  rotate(angle: number, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  rotateSync(angle: number): void {
    throw new Error('Method not implemented.');
  }

  flip(horizontal: boolean, vertical: boolean, callback: AsyncCallback<void, void>): void;
  flip(horizontal: boolean, vertical: boolean): Promise<void>;
  flip(horizontal: boolean, vertical: boolean, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  flipSync(horizontal: boolean, vertical: boolean): void {
    throw new Error('Method not implemented.');
  }

  crop(region: image.Region, callback: AsyncCallback<void, void>): void;
  crop(region: image.Region): Promise<void>;
  crop(region: image.Region, callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  cropSync(region: image.Region): void {
    throw new Error('Method not implemented.');
  }

  getColorSpace(): colorSpaceManager.ColorSpaceManager {
    throw new Error('Method not implemented.');
  }

  marshalling(sequence: rpc.MessageSequence): void {
    throw new Error('Method not implemented.');
  }

  unmarshalling(sequence: rpc.MessageSequence): Promise<image.PixelMap> {
    throw new Error('Method not implemented.');
  }

  setColorSpace(colorSpace: colorSpaceManager.ColorSpaceManager): void {
    throw new Error('Method not implemented.');
  }

  public isStrideAlignment: boolean = false;

  applyColorSpace(targetColorSpace: colorSpaceManager.ColorSpaceManager, callback: AsyncCallback<void, void>): void;
  applyColorSpace(targetColorSpace: colorSpaceManager.ColorSpaceManager): Promise<void>;
  applyColorSpace(targetColorSpace: colorSpaceManager.ColorSpaceManager,
    callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  convertPixelFormat(targetPixelFormat: image.PixelMapFormat): Promise<void> {
    throw new Error('Method not implemented.');
  }

  release(callback: AsyncCallback<void, void>): void;
  release(): Promise<void>;
  release(callback?: AsyncCallback<void, void>): void | Promise<void> {
    throw new Error('Method not implemented.');
  }

  setTransferDetached(detached: boolean): void {
    throw new Error('Method not implemented.');
  }

  getMetadata(key: image.HdrMetadataKey): image.HdrMetadataValue {
    throw new Error('Method not implemented.');
  }

  setMemoryNameSync(name: string): void {
    throw new Error('Method not implemented.');
  }

  cloneSync(): image.PixelMap {
    throw new Error('Method not implemented.');
  }

  clone(): Promise<image.PixelMap> {
    throw new Error('Method not implemented.');
  }

  setMetadata(key: image.HdrMetadataKey, value: image.HdrMetadataValue): Promise<void> {
    throw new Error('Method not implemented.');
  }
}