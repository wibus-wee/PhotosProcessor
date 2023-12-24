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
        // let id = compressor.compress(path: path!, name: name!, config: config)
        let compress = compressor.compress(path: path!, name: name!, config: config)
        if (compress == nil) {
            print("[E] Compress failed.")
            return nil
        }
        let id = compress!.id
        let processedPath = compress!.processedPath
        if (configuration.useProcessedFileToProcess) {
            self.setup(url: URL(fileURLWithPath: processedPath))
        } else {
            self.refresh()
        }
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
        InternalKit.useFilePanel(title: "Choose Image", message: "Select the image file to process", action: { url in
            if url == nil {
                print("[E] No image selected")
                return
            }
            self.reset() // Reset image

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

    func refresh() {
        if !self.inited {
            print("[W] Image not inited. Refresh failed.")
            return
        }
        print("[I] Refreshed image: \(self.url!)")
        self.setup(url: self.url!)
    }

    func saveAs() {
        if !self.inited {
            print("[W] Image not inited. SaveAs failed.")
            return
        }
        InternalKit.saveFilePanel(title: "Save Image", message: "Save the image file", action: { url in
            if url == nil {
                print("[E] No image selected")
                return
            }
            let cgImage = self.image?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            if cgImage == nil {
                print("[E] Failed to get cgImage")
                return
            }
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage!)
            let data = bitmapRep.representation(using: .png, properties: [:])
            do {
                try data?.write(to: url!)
            } catch {
                print("[E] Failed to write image to file: \(error)")
                return
            }
        })
    }
}
