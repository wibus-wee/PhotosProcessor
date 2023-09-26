//
//  GetImageMetadata.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import ImageIO
import SwiftUI

struct MetadataKey: Hashable {
    var key: CFString
    var area: String
}

class ImageMetadata {
    var metadata: [String: Any]?
    var url: URL?
    
    init(url: URL) {
        self.url = url
        self.metadata = getImageMetadata(url: url)
    }
    
    func getMetadata() -> [String: Any]? {
        return self.metadata
    }
    
    func getMetadata(key: CFString) -> Any? {
        guard let metadata = self.metadata else {
            return nil
        }
        return metadata[key as String]
    }
    
    func getMetadata(key: MetadataKey) -> Any? {
        guard let metadata = self.metadata else {
            return nil
        }
        guard let area = metadata["{\(key.area)}"] as? [String: Any] else {
            return nil
        }

        guard let value = area[key.key as String] else {
            return nil
        }

        return value
    }
    
    func getColorProfile() -> String? {
        guard let metadata = self.metadata else {
            return nil
        }
        guard let colorProfile = metadata[kCGImagePropertyProfileName as String] as? String else {
            return nil
        }
        return colorProfile
    }
}