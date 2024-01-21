//
//  LightWatermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2024/1/21.
//

import CoreGraphics
import Foundation
import SwiftUI

class LightWatermark: WatermarkProtocol {
    func encode(data: String, image: NSImage, completionBlock: @escaping (NSImage?, Error?) -> Void) {
        print("[*] LightWatermark.encoding")
        let image = image
        let data = data
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let imageScale = image.size.width / imageWidth
        let imageColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let bitmapContext = CGContext(data: nil, width: Int(imageWidth), height: Int(imageHeight), bitsPerComponent: 8, bytesPerRow: 0, space: imageColorSpace, bitmapInfo: bitmapInfo)!
        bitmapContext.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: imageRect)
        let textFontAttributes = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12 * imageScale),
            NSAttributedString.Key.foregroundColor: NSColor.white,
        ]
        let text = data as NSString
        let textSize = text.size(withAttributes: textFontAttributes)
        let textRect = CGRect(x: imageWidth - textSize.width - 10 * imageScale, y: imageHeight - textSize.height - 10 * imageScale, width: textSize.width, height: textSize.height)
        bitmapContext.setFillColor(NSColor.black.withAlphaComponent(0.5).cgColor)
        bitmapContext.fill(textRect)
        text.draw(in: textRect, withAttributes: textFontAttributes)
        let watermarkedCGImage = bitmapContext.makeImage()!
        let watermarkedImage = NSImage(cgImage: watermarkedCGImage, size: image.size)
        completionBlock(watermarkedImage, nil)
    }

    func decode(from image: NSImage, completionBlock: @escaping (Data?, Error?) -> Void) {
        let image = image
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let imageScale = image.size.width / imageWidth
        let imageColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let bitmapContext = CGContext(data: nil, width: Int(imageWidth), height: Int(imageHeight), bitsPerComponent: 8, bytesPerRow: 0, space: imageColorSpace, bitmapInfo: bitmapInfo)!
        bitmapContext.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: imageRect)
        let textRect = CGRect(x: imageWidth - 100 * imageScale, y: imageHeight - 100 * imageScale, width: 100 * imageScale, height: 100 * imageScale)
        let textImage = bitmapContext.makeImage()!.cropping(to: textRect)!
        let textBitmapContext = CGContext(data: nil, width: Int(textRect.width), height: Int(textRect.height), bitsPerComponent: 8, bytesPerRow: 0, space: imageColorSpace, bitmapInfo: bitmapInfo)!
        textBitmapContext.draw(textImage, in: CGRect(x: 0, y: 0, width: textRect.width, height: textRect.height))
        let textImagePointer = textBitmapContext.data!
        let textImageBuffer = UnsafeBufferPointer(start: textImagePointer.assumingMemoryBound(to: UInt8.self), count: textBitmapContext.height * textBitmapContext.bytesPerRow)
        let textImageBytes = Array(textImageBuffer)
        let textImageBytesCount = textImageBytes.count
        var textBytes = [UInt8]()
        for i in 0..<textImageBytesCount {
            if i % 4 == 3 {
                textBytes.append(textImageBytes[i])
            }
        }
        let textData = Data(bytes: textBytes, count: textBytes.count)
        completionBlock(textData, nil)
    }
}
