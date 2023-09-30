//
//  ProcessImage.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/30.
//

import Foundation

class ProcessImage: NSObject, ObservableObject {
    static let shared = ProcessImage()
    let compressor = Compressor()
    @Published var imageMetadata: ImageMetadata?
    @Published var metadata: [String: Any]?
    @Published var name: String?
    @Published var url: URL?
    @Published var path: String?
    @Published var inited: Bool = false
    
    /// Compress image
    /// - Parameter config: CompressorConfig
    /// - Returns: UUID
    func compress(config: CompressorConfig) -> UUID? {
        let id = compressor.compress(path: path!, name: name!, config: config)
        return id;
    }
    
    func reset() {
        self.imageMetadata = nil
        self.metadata = nil
        self.name = nil
        self.url = nil
        self.path = nil
        self.inited = false
        print("[I] Reset image")
    }
    
    func setup() {
        self.reset()
        InternalKit.useFilePanel(title: "Choose Image", message: "Select the image file to process", action: { url in
            self.url = url
            self.imageMetadata = ImageMetadata(url: url!)
            self.metadata = self.imageMetadata?.getMetadata()
            self.name = url!.lastPathComponent
            self.path = url!.path
            self.inited = true
            print("[I] Loaded image: \(self.url!)")
        })
    }
}
