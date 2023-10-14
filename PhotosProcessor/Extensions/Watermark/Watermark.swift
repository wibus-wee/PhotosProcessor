//
//  Watermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI
import CoreGraphics


class Watermark {
    private var impl = LSBWatermark()

    init() {
        impl = LSBWatermark()
    }

    func decode(_ image: NSImage) -> Void {
        // Change to CGImage
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        impl.decode(from: cgImage!) { (data, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data {
                    let string = String(data: data, encoding: .utf8)
                    print(string)
                }
            }
        }
    }

    func encode(_ image: NSImage, text: String) -> Void {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        impl.encode(data: text, image: cgImage!) { (image, error) in
            if let error = error {
                print(error)
            } else {
                if let image = image {
                    
                }
            }
        }
    }

    func encode(_ image: NSImage, text: String, completionBlock: @escaping (CGImage?, Error?) -> Void) -> Void {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        impl.encode(data: text, image: cgImage!) { (image, error) in
            if let error = error {
                print(error)
            } else {
                if let image = image {
                    completionBlock(image, nil)
                }
            }
        }
    }
}
