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
        self.metadata = self.getImageMetadata(url: url)
    }

    func getImageMetadata(url: URL) -> [String: Any]? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }
        return metadata
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

    func editMetadata(key: MetadataKey, value: Any) -> Bool {
        guard let url = self.url else {
            return false
        }
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        guard let imageDestination = CGImageDestinationCreateWithURL(url as CFURL, CGImageSourceGetType(imageSource)!, 1, nil) else {
            return false
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return false
        }
        var metadataToBeWritten = metadata
        guard var area = metadataToBeWritten["{\(key.area)}"] as? [String: Any] else {
            return false
        }
        area[key.key as String] = value
        metadataToBeWritten["{\(key.area)}"] = area
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, metadataToBeWritten as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return true
    }

    func copyMetadata(from: MetadataKey, to: MetadataKey) -> Bool {
        guard let url = self.url else {
            return false
        }
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        guard let imageDestination = CGImageDestinationCreateWithURL(url as CFURL, CGImageSourceGetType(imageSource)!, 1, nil) else {
            return false
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return false
        }
        var metadataToBeWritten = metadata
        guard let area = metadataToBeWritten["{\(from.area)}"] as? [String: Any] else {
            return false
        }
        guard let value = area[from.key as String] else {
            return false
        }
        guard var toArea = metadataToBeWritten["{\(to.area)}"] as? [String: Any] else {
            return false
        }
        toArea[to.key as String] = value
        metadataToBeWritten["{\(to.area)}"] = toArea
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, metadataToBeWritten as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return true
    }

    func removeMetadata(key: MetadataKey) -> Bool {
        guard let url = self.url else {
            return false
        }
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        guard let imageDestination = CGImageDestinationCreateWithURL(url as CFURL, CGImageSourceGetType(imageSource)!, 1, nil) else {
            return false
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return false
        }
        var metadataToBeWritten = metadata
        guard var area = metadataToBeWritten["{\(key.area)}"] as? [String: Any] else {
            return false
        }
        area.removeValue(forKey: key.key as String)
        metadataToBeWritten["{\(key.area)}"] = area
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, metadataToBeWritten as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return true
    }

    func addMetadata(key: MetadataKey, value: Any) -> Bool {
        guard let url = self.url else {
            return false
        }
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        guard let imageDestination = CGImageDestinationCreateWithURL(url as CFURL, CGImageSourceGetType(imageSource)!, 1, nil) else {
            return false
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return false
        }
        var metadataToBeWritten = metadata
        guard var area = metadataToBeWritten["{\(key.area)}"] as? [String: Any] else {
            return false
        }
        area[key.key as String] = value
        metadataToBeWritten["{\(key.area)}"] = area
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, metadataToBeWritten as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return true
    }
}
