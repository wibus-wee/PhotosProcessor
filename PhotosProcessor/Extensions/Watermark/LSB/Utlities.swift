//
//  Utlities.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
// 
// Learn from ISStego
//

import Foundation
import CoreGraphics
import SwiftUI

enum LSBUtlities {
    static let INITIAL_SHIFT = 7
    static let BYTES_PER_PIXEL = 4
    static let BITS_PER_COMPONENT = 8
    static let BYTES_OF_LENGTH = 4

    static let DATA_PREFIX = "<m>"
    static let DATA_SUFFIX = "</m>"

    enum ErrorDomainCode {
        case notDefined
        case dataTooBig
        case imageTooSmall
        case noDataInImage
    }
    static let ErrorDomain = "LSBErrorDomain"

    /**
     This function checks if a string contains a substring

     - Parameters:
       - string: The string to check
       - substring: The substring to check for
     */
    static func contains(string: String, substring: String) -> Bool {
        return string.range(of: substring, options: .caseInsensitive) != nil
    }

    static func substring(string: String, prefix: String, suffix: String) -> String? {
        if let prefixRange = string.range(of: prefix) {
            if let suffixRange = string.range(of: suffix) {
                let range = prefixRange.upperBound..<suffixRange.lowerBound
                return String(string[range])
            }
        }
        return nil
    }

    static func errorForDomainCode(code: ErrorDomainCode) -> NSError {
        var description = "not defined"
        switch code {
        case .dataTooBig:
            description = "The data is too big"
        case .imageTooSmall:
            description = "Image is too small: must have at least \(minPixels()) pixels"
        case .noDataInImage:
            description = "There is no data in image"
        default:
            break
        }
        return NSError(domain: ErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: description])
    }

    static func cgImageCreateWithImage(image: Any) -> CGImage? {
        var imageRef: CGImage?
        // #if os(iOS)
        // guard let image = image as? UIImage else {
        //   return nil
        // }
        // imageRef = image.cgImage
        // #else
        guard let image = image as? NSImage else {
            return nil
        }
        guard let data = image.tiffRepresentation else {
            return nil
        }
        guard let dataRef = data as CFData? else {
            return nil
        }
        guard let source = CGImageSourceCreateWithData(dataRef, nil) else {
            return nil
        }
        imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil)
        // #endif
        return imageRef
    }

    static func image(imageRef: CGImage) -> Any {
        var image: Any?
        // #if os(iOS)
        // image = UIImage(cgImage: imageRef)
        // #else
        image = NSImage(cgImage: imageRef, size: .zero)
        // #endif
        return image!
    }
}

extension LSBUtlities {
    static func sizeOfInfoLength() -> Int {
        return BYTES_OF_LENGTH * BITS_PER_COMPONENT
    }

    static func minPixelsToMessage() -> Int {
        return (DATA_PREFIX.count + DATA_SUFFIX.count) * BITS_PER_COMPONENT
    }

    static func minPixels() -> Int {
        return sizeOfInfoLength() + minPixelsToMessage()
    }
}

extension LSBUtlities {
    enum PixelColor {
        case red
        case green
        case blue
    }

    static func color(_ x: UInt32, shift: Int) -> UInt32 {
        return mask8(x >> (8 * shift))
    }

    static func newPixel(_ pixel: UInt32, shiftedBits: UInt32, shift: Int) -> UInt32 {
        let bit = (shiftedBits & 1) << (8 * shift)
        let colorAndNot = pixel & ~(1 << (8 * shift))
        return colorAndNot | bit
    }

    static func addBits(_ number1: UInt32, number2: UInt32, shift: Int) -> UInt32 {
        return (number1 | mask8(number2) << (8 * shift))
    }

    static func colorToStep(_ step: UInt32) -> PixelColor {
        if step % 3 == 0 {
            return .blue
        } else if step % 2 == 0 {
            return .green
        } else {
            return .red
        }
    }

    static func mask8(_ x: UInt32) -> UInt32 {
        return x & 0xFF
    }
}
