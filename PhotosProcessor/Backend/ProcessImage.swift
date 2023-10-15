//
//  ProcessImage.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/30.
//

import Foundation
import SwiftUI

class ProcessImage: NSObject, ObservableObject {
    static let shared = ProcessImage()
    let compressor = Compressor()
    @Published var imageMetadata: ImageMetadata?
    @Published var metadata: [String: Any]?
    @Published var name: String?
    @Published var url: URL?
    @Published var path: String?
    @Published var inited: Bool = false
    @Published var image: NSImage?
    
    /// Compress image
    /// - Parameter config: CompressorConfig
    /// - Returns: UUID
    func compress(config: CompressorConfig) -> UUID? {
        if !self.inited {
            print("[W] Image not inited. Compress failed.")
            return nil
        }
        let id = compressor.compress(path: path!, name: name!, config: config)
        return id;
    }
    
    func reset() {
        self.imageMetadata = nil
        self.metadata = nil
        self.name = nil
        self.url = nil
        self.path = nil
        self.image = nil
        self.inited = false
        print("[I] Reset image")
    }
    
    func setup() {
        self.reset()
        InternalKit.useFilePanel(title: "Choose Image", message: "Select the image file to process", action: { url in
            if url == nil {
                print("[E] No image selected")
                return
            }
            self.url = url
            self.imageMetadata = ImageMetadata(url: url!)
            self.metadata = self.imageMetadata?.getMetadata()
            self.name = url!.lastPathComponent
            self.path = url!.path
            self.image = NSImage(contentsOf: url!)
            self.inited = true
            print("[I] Loaded image: \(self.url!)")
        })
    }

    func setup(url: URL) {
        self.url = url
        self.imageMetadata = ImageMetadata(url: url)
        self.metadata = self.imageMetadata?.getMetadata()
        self.name = url.lastPathComponent
        self.path = url.path
        self.image = NSImage(contentsOf: url)
        self.inited = true
        print("[I] Loaded image: \(self.url!)")
    }

    func setup(image: NSImage) {
        print("[E] Not implemented")
        return Void()
        self.name = "Untitled(\(UUID().uuidString))"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.name!)
        let data = image.tiffRepresentation
        do {
            try data?.write(to: url)
        } catch {
            print("[E] Failed to write image to temp file: \(error)")
            return
        }
        self.imageMetadata = ImageMetadata(url: url)
        self.metadata = self.imageMetadata?.getMetadata()
        self.url = url
        self.path = url.path
        self.image = image
        self.inited = true
        print("[I] Loaded image: \(self.url!)")
    }
}
