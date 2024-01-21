//
//  Watermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI
import CoreGraphics


protocol WatermarkProtocol {
    func encode(data: String, image: NSImage, completionBlock: @escaping (NSImage?, Error?) -> Void)
    func decode(from image: NSImage, completionBlock: @escaping (Data?, Error?) -> Void)
}

class Watermark {
    @State private var impl: WatermarkProtocol = LSBWatermark()
    
    enum WatermarkType {
        case LSB
        case Light
    }

    private var type: WatermarkType = .LSB {
        didSet {
            updateImpl()
        }
    }

    private func updateImpl() {
        switch type {
        case .LSB:
            impl = LSBWatermark()
        case .Light:
            impl = LightWatermark()
        }
        
    }

    func setWatermarkType(_ type: WatermarkType) {
        self.type = type
        updateImpl()
        print("[I] Watermark type set to \(type) successfully. impl: \(impl)")
    }
    
    func decode(_ image: NSImage, completionBlock: @escaping (Data?, Error?) -> Void) -> Void {
        impl.decode(from: image) { (data, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data {
                    let string = String(data: data, encoding: .utf8)
                    print(string!)
                    completionBlock(data, nil)
                }
            }
        }
    }

    func encode(_ image: NSImage, text: String, completionBlock: @escaping (NSImage?, Error?) -> Void) -> Void {
        impl.encode(data: text, image: image) { (image, error) in
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
