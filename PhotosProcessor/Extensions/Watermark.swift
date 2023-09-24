//
//  Watermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

class Watermark {

    // 通过传入的NSImage添加可见水印
    func visibleWatermark(_ image: NSImage) -> NSImage {
        // 获取输入图像的CGImage
        let inputCGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let inputWidth = inputCGImage.width
        let inputHeight = inputCGImage.height

        // 创建一个色彩空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // 定义像素格式
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let inputBytesPerRow = bytesPerPixel * inputWidth

        // 创建用于存储像素数据的数组
        var inputPixels = [UInt32](repeating: 0, count: inputHeight * inputWidth)

        // 创建绘制上下文
        let context = CGContext(data: &inputPixels,
                                width: inputWidth,
                                height: inputHeight,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: inputBytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)!

        // 在绘制上下文中绘制输入图像
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight))

        // 处理像素数据以添加水印
        for j in 0..<inputHeight {
            for i in 0..<inputWidth {
                let currentPixel = inputPixels[Int(j * inputWidth) + Int(i)]
                let thisR = R(currentPixel)
                let thisG = G(currentPixel)
                let thisB = B(currentPixel)
                let thisA = A(currentPixel)

                let newR = mixedCalculation(thisR)
                let newG = mixedCalculation(thisG)
                let newB = mixedCalculation(thisB)

                inputPixels[Int(j * inputWidth) + Int(i)] = RGBAMake(newR, newG, newB, thisA)
            }
        }

        // 创建新的CGImage
        let newCGImage = context.makeImage()!

        // 创建新的NSImage
        let processedImage = NSImage(cgImage: newCGImage, size: image.size)

        return processedImage
    }

    // 对像素值进行混合计算以添加水印
    func mixedCalculation(_ originValue: UInt32) -> UInt32 {
        let intOriginValue = Int(originValue)
        let mixValue = 1
        var resultValue = 0

        // 执行混合计算
        resultValue = intOriginValue - (255 - intOriginValue) * (255 - mixValue) / mixValue

        // 确保结果值在合理范围内
        if resultValue < 0 {
            resultValue = 0
        }

        return UInt32(resultValue)
    }

    // 在图像上添加水印文本
    func addWatermark(_ image: NSImage, text: String) -> NSImage {
        // 创建字体和文本属性
        let font = NSFont.systemFont(ofSize: 32)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                          .foregroundColor: NSColor(red: 0, green: 0, blue: 0, alpha: 0.01)]

        var newImage = image
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var idx0: CGFloat = 0
        var idx1: CGFloat = 0
        let textSize = text.size(withAttributes: attributes)

        // 遍历图像并添加文本水印
        while y < image.size.height {
            y = (textSize.height * 2) * idx1

            while x < image.size.width {
                newImage = addWatermark(newImage, text: text, textPoint: CGPoint(x: x, y: y), attributedString: attributes)
                x = (textSize.width * 2) * idx0
                idx0 += 1
            }

            x = 0
            idx0 = 0
            idx1 += 1
        }

        return newImage
    }

    // 异步添加水印文本
    func addWatermark(_ image: NSImage, text: String, completion: @escaping (NSImage?) -> Void) {
        DispatchQueue.global(qos: .default).async {
            let result = self.addWatermark(image, text: text)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // 在图像上添加水印文本
    func addWatermark(_ image: NSImage, text: String, textPoint point: CGPoint, attributedString attributes: [NSAttributedString.Key: Any]) -> NSImage {
        // 创建新的NSImage
        let newImage = NSImage(size: image.size)

        // 开始绘制
        newImage.lockFocus()

        // 在新的NSImage上绘制原始图像
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        // 计算文本绘制区域
        let textSize = text.size(withAttributes: attributes)
        let rect = NSRect(x: point.x, y: point.y, width: textSize.width, height: textSize.height)

        // 在新的NSImage上绘制文本
        text.draw(in: rect, withAttributes: attributes)

        // 结束绘制
        newImage.unlockFocus()

        return newImage
    }

    // 帮助方法：提取8位整数
    private func Mask8(_ x: UInt32) -> UInt32 {
        return x & 0xFF
    }

    // 帮助方法：提取红色分量
    private func R(_ x: UInt32) -> UInt32 {
        return Mask8(x)
    }

    // 帮助方法：提取绿色分量
    private func G(_ x: UInt32) -> UInt32 {
        return Mask8(x >> 8)
    }

    // 帮助方法：提取蓝色分量
    private func B(_ x: UInt32) -> UInt32 {
        return Mask8(x >> 16)
    }

    // 帮助方法：提取Alpha分量
    private func A(_ x: UInt32) -> UInt32 {
        return Mask8(x >> 24)
    }

    // 帮助方法：创建新的RGBA值
    private func RGBAMake(_ r: UInt32, _ g: UInt32, _ b: UInt32, _ a: UInt32) -> UInt32 {
        return Mask8(r) | (Mask8(g) << 8) | (Mask8(b) << 16) | (Mask8(a) << 24)
    }
}

