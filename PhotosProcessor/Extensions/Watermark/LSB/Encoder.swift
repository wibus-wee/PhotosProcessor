//
//  Encoder.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
//

import Foundation
import CoreGraphics

class LSBEncoder {
    private var currentShift = 7
    private var currentCharacter = 0
    private var step: UInt32 = 0
    private var currentDataToHide: String = ""

    static func base64(from data: String) -> String {
        let dataOfString = data.data(using: .utf8)
        return dataOfString!.base64EncodedString(options: .init(rawValue: 0))
    }

    func reset() {
        currentShift = LSBUtlities.INITIAL_SHIFT
        currentCharacter = 0
        // step = 0
        // currentDataToHide = ""
    }

    func message(toHide data: String) -> String {
        let base64 = LSBEncoder.base64(from: data)
        return "\(LSBUtlities.DATA_PREFIX)\(base64)\(LSBUtlities.DATA_SUFFIX)"
    }

    func newPixel(_ pixel: UInt32) -> UInt32 {
        let color = newColor(pixel)
        step += 1
        return color
    }

    func newColor(_ color: UInt32) -> UInt32 {
        if currentDataToHide.count > currentCharacter {
            let asciiCode = currentDataToHide[currentDataToHide.index(currentDataToHide.startIndex, offsetBy: currentCharacter)].asciiValue!
            
            let shiftedBits = asciiCode >> UInt8(currentShift)
            
            if currentShift == 0 {
                currentShift = LSBUtlities.INITIAL_SHIFT
                currentCharacter += 1
            } else {
                currentShift -= 1
            }
            
            return LSBUtlities.newPixel(color, shiftedBits: UInt32(shiftedBits), shift: Int(step))
        }
        
        return color
    }

    func hideData(_ data: String, in pixels: inout [UInt32], withSize size: Int) throws -> Bool {
        var success = false
        
        let messageToHide = message(toHide: data)
        
        var dataLength = UInt32(messageToHide.count)
        
        if dataLength * UInt32(LSBUtlities.BITS_PER_COMPONENT) < UInt32(size - LSBUtlities.sizeOfInfoLength()) {
        //  dataLength <= UInt32(Int.max) && 
            reset()
            
            let data = Data(bytes: &dataLength, count: LSBUtlities.BYTES_OF_LENGTH)
            
            let lengthDataInfo = String(data: data, encoding: .ascii)
            
            var pixelPosition: UInt32 = 0
            
            currentDataToHide = lengthDataInfo!
            
            while pixelPosition < LSBUtlities.sizeOfInfoLength() {
                pixels[Int(pixelPosition)] = newPixel(pixels[Int(pixelPosition)])
                pixelPosition += 1
            }
            
            reset()
            
            let pixelsToHide = messageToHide.count * LSBUtlities.BITS_PER_COMPONENT
            
            currentDataToHide = messageToHide
            
            let ratio = Double(size - Int(pixelPosition))/Double(pixelsToHide)
            
            let salt = Int(ratio)
            
            while pixelPosition <= UInt32(size) {
                pixels[Int(pixelPosition)] = newPixel(pixels[Int(pixelPosition)])
                pixelPosition += UInt32(salt)
            }
            
            success = true
        } else {
            throw LSBUtlities.errorForDomainCode(code: LSBUtlities.ErrorDomainCode.dataTooBig)
        }
        
        return success
    }
    
    func stegoImage(for image: Any, data: Any) throws -> Any? {
        // guard let inputImage = image as? CGImage else {
        //     return nil
        // }
        let inputImage = image as! CGImage
        
        guard let dataString = data as? String else {
            return nil
        }
        
        let width = inputImage.width
        let height = inputImage.height
        let size = height * width
        
        var pixels = [UInt32](repeating: 0, count: size)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixels,
                                width: width,
                                height: height,
                                bitsPerComponent: LSBUtlities.BITS_PER_COMPONENT,
                                bytesPerRow: LSBUtlities.BYTES_PER_PIXEL * width,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue).rawValue)
        
        context?.draw(inputImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var processedImage: Any?
        
        if size >= LSBUtlities.minPixels() {
            let success = try self.hideData(dataString, in: &pixels, withSize: size)
            
            if success {
                if let newCGImage = context?.makeImage() {
                    processedImage = LSBUtlities.image(imageRef: newCGImage)
                }
            }
        } else {
            throw LSBUtlities.errorForDomainCode(code: LSBUtlities.ErrorDomainCode.imageTooSmall)
        }
        
        return processedImage
    }
    
    func stegoImageForImage(image: CGImage, data: String) throws -> CGImage? {
        let width = image.width
        let height = image.height
        let size = height * width
        
        var pixels = [UInt32](repeating: 0, count: size)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixels,
                                width: width,
                                height: height,
                                bitsPerComponent: LSBUtlities.BITS_PER_COMPONENT,
                                bytesPerRow: LSBUtlities.BYTES_PER_PIXEL * width,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue).rawValue)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var processedImage: CGImage?
        
        if size >= LSBUtlities.minPixels() {
            let success = try self.hideData(data, in: &pixels, withSize: size)
            
            if success {
                if let newCGImage = context?.makeImage() {
                    processedImage = newCGImage
                }
            }
        } else {
            throw LSBUtlities.errorForDomainCode(code: LSBUtlities.ErrorDomainCode.imageTooSmall)
        }
        
        return processedImage
    }
}
