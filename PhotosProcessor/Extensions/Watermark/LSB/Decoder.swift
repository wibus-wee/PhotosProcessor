//
//  Decoder.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
//
import Foundation
import CoreGraphics

class LSBDecoder {
  private var currentShift = LSBUtlities.INITIAL_SHIFT
  private var bitsCharacter = 0
  private var data = ""
  private var step: UInt32 = 0
  private var length: UInt32 = 0

  func hasData() -> Bool {
    return (data.count > 0 && data.contains(LSBUtlities.DATA_PREFIX) && data.contains(LSBUtlities.DATA_SUFFIX)) ? true : false
  }

  func getCharacter() {
    let character = String(format: "%c", bitsCharacter)
    bitsCharacter = 0
    if data.count > 0 {
      data = "\(data)\(character)"
    } else {
      data = character
    }
  }

  func getLength() {
      length = LSBUtlities.addBits(length, number2: UInt32(bitsCharacter), shift: Int(step) % (LSBUtlities.BITS_PER_COMPONENT - 1))
    bitsCharacter = 0
  }

  func getDataWithColor(color: UInt32) {
    if currentShift == 0 {
      let bit = color & 1
        bitsCharacter = Int((bit << currentShift)) | bitsCharacter
      if step < LSBUtlities.sizeOfInfoLength() {
        getLength()
      } else {
        getCharacter()
      }
      currentShift = LSBUtlities.INITIAL_SHIFT
    } else {
      let bit = color & 1
        bitsCharacter = Int((bit << currentShift)) | bitsCharacter
      currentShift -= 1
    }
    step += 1
  }

  func getDataWithPixel(pixel: UInt32) {
    // LSBUtlities.colorToStep(step)
    getDataWithColor(color: LSBUtlities.color(pixel, shift: Int(step) % (LSBUtlities.BITS_PER_COMPONENT - 1)))
  }

  func reset() {
    currentShift = LSBUtlities.INITIAL_SHIFT
    bitsCharacter = 0
  }

  func searchDatainPixels(pixels: UnsafeMutablePointer<UInt32>, size: UInt) {
    reset()
    var pixelPosition: UInt = 0
    while pixelPosition < LSBUtlities.sizeOfInfoLength() {
      getDataWithPixel(pixel: pixels[Int(pixelPosition)])
      pixelPosition += 1
    }
    reset()
    let pixelsToHide = UInt64(length) * UInt64(LSBUtlities.BITS_PER_COMPONENT)
    let ratio = (size - pixelPosition) / UInt(pixelsToHide)
    let salt = ratio
    while pixelPosition <= size {
      getDataWithPixel(pixel: pixels[Int(pixelPosition)])
      pixelPosition += salt
      if data.contains(LSBUtlities.DATA_SUFFIX) {
        break
      }
    }
  }

  func hasDataInImage(image: CGImage) -> Bool {
    let width = image.width
    let height = image.height
    let size = height * width
    let pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixels,
                            width: width,
                            height: height,
                            bitsPerComponent: LSBUtlities.BITS_PER_COMPONENT,
                            bytesPerRow: LSBUtlities.BYTES_PER_PIXEL * width,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
    context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
      searchDatainPixels(pixels: pixels, size: UInt(size))
    free(pixels)
    return hasData()
  }

  func decodeStegoImage(image: CGImage) -> Data? {
    if hasDataInImage(image: image) {
     guard let base64 = LSBUtlities.substring(string: data, prefix: LSBUtlities.DATA_PREFIX, suffix: LSBUtlities.DATA_SUFFIX) else {
        return nil
      }
      return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    return nil
  }


}
