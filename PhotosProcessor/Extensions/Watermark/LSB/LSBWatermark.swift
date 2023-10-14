//
//  LSBWatermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
//

import Foundation
import CoreGraphics

class LSBWatermark {
    func encode(data: String, image: CGImage, completionBlock: @escaping (CGImage?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                let encoder = LSBEncoder()
                var processedImage: CGImage?
                do {
                    processedImage = try (encoder.stegoImage(for: image, data: data) as! CGImage)
                } catch {
                    print(error)
                }
                completionBlock(processedImage, nil)
            }
        }
    }

    func decode(from image: CGImage, completionBlock: @escaping (Data?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                let decoder = LSBDecoder()
                var data: Data?
                data = decoder.decodeStegoImage(image: image)
                completionBlock(data, nil)
            }
        }
    }
}
