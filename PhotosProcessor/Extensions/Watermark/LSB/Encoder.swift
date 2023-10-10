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
            let success = try hideData(dataString, in: &pixels, withSize: size)
            
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
}
