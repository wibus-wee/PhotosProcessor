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
        let url = self.url!
        let urlComponents = url.pathComponents
        let fileName = urlComponents[urlComponents.count - 1]
        let fileNameComponents = fileName.split(separator: ".")
        let fileExtension = fileNameComponents[fileNameComponents.count - 1]
        let newFileName = "\(fileNameComponents[0])_metadata_edited.\(fileExtension)"
        let newFilePath = url.deletingLastPathComponent().appendingPathComponent(newFileName)
        let newFileURL = URL(fileURLWithPath: newFilePath.path)

        let area: String? = key.area.isEmpty ? nil : "{\(key.area)}"
        let key = key.key
        let value = value as CFTypeRef
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        guard let imageDestination = CGImageDestinationCreateWithURL(newFileURL as CFURL, CGImageSourceGetType(imageSource)!, 1, nil) else {
            return false
        }
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return false
        }
        var newMetadata = self.metadata!
        if area == nil {
            newMetadata[key as String] = value
        } else {
            var newArea = newMetadata[area!] as? [String: Any]
            if newArea == nil {
                newArea = [String: Any]()
            }
            newArea![key as String] = value
            newMetadata[area!] = newArea
        }
        print("[*] metadata before edited: \(self.metadata!)")
        print("[*] metadata edited: \(newMetadata)")
        
        CGImageDestinationAddImage(imageDestination, image, newMetadata as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        
        return true
    }

    func copyMetadata(from: MetadataKey, to: MetadataKey) -> Bool {
        return false
    }

    func removeMetadata(key: MetadataKey) -> Bool {
        return false
    }

    func addMetadata(key: MetadataKey, value: Any) -> Bool {
        return false
    }
}
