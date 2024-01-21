//
//  LSBWatermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/10/10.
//

import Foundation
import SwiftUI

class LSBWatermark: WatermarkProtocol {
    func encode(data: String, image: NSImage, completionBlock: @escaping (NSImage?, Error?) -> Void) {
        // DispatchQueue.global(qos: .background).async {
            // autoreleasepool {
                // Transform image to NSImage
                // let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
                ISSteganographer.hideData(data, withImage: image) { hiddenImage, error in 
                        if let error = error {
                            print("[E] LSBWatermark.encode: \(error)")
                        }
                        if let hiddenImage = hiddenImage as? NSImage {
                            DispatchQueue.main.async {
                                completionBlock(hiddenImage, nil)
                            }
                        }
                  }
            // }
        // }
    }

    func decode(from image: NSImage, completionBlock: @escaping (Data?, Error?) -> Void) {
        // DispatchQueue.global(qos: .background).async {
            // autoreleasepool {
                // let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
                ISSteganographer.data(fromImage: image) { data, error in
                        if let error = error {
                            print("[E] LSBWatermark.decode: \(error)")
                        } else if let data = data, let hiddenData = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                completionBlock(data, nil)
                            }
                        }
                    }
            // }
        // }
    }
}
