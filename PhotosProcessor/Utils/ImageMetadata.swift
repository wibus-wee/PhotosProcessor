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

func getImageMetadata(image: NSImage) -> [String: Any]? {
    guard let imageData = image.tiffRepresentation else {
        return nil
    }
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
        return nil
    }
    let metadataOptions: [CFString: Any] = [
        kCGImageSourceShouldAllowFloat: true
    ]
    guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, metadataOptions as CFDictionary) as? [String: Any] else {
        return nil
    }
    
    return metadata
}

func getImageMetadata(url: URL) -> [String: Any]? {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        return nil
    }
    let metadataOptions: [CFString: Any] = [
        kCGImageSourceShouldAllowFloat: true
    ]
    guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, metadataOptions as CFDictionary) as? [String: Any] else {
        return nil
    }
    
    return metadata
}

func getImageMetadata(url: URL, key: CFString) -> Any? {
    
    guard let metadata = getImageMetadata(url: url) else {
        return nil
    }
    
    return metadata[key as String]
}

func getImageMetadata(url: URL, key: MetadataKey) -> Any? {
    
    guard let metadata = getImageMetadata(url: url) else {
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

func getColorProfileFromMetadata(metadata: [String: Any]) -> String? {
    guard let colorProfile = metadata[kCGImagePropertyProfileName as String] as? String else {
        return nil
    }
    return colorProfile
}

func getImageMetadataFromMDItem(url: URL, key: CFString) -> Any? {
    print("[*] getImageMetadataFromMDItem: \(key)")
    guard let mdItem = MDItemCreateWithURL(kCFAllocatorDefault, url as CFURL) else {
        return nil
    }
    guard let mdItemMetadata = MDItemCopyAttributes(mdItem, [key] as CFArray) as? [String: Any] else {
        return nil
    }
    print("[*] getImageMetadataFromMDItem: \(mdItemMetadata), \([key] as CFArray)")
    return mdItemMetadata[key as String]
}

func getImageMetadataFromMDItem(url: URL, key: CFArray) -> [String: Any]? {
    guard let mdItem = MDItemCreateWithURL(kCFAllocatorDefault, url as CFURL) else {
        return nil
    }
    guard let mdItemMetadata = MDItemCopyAttributes(mdItem, key) as? [String: Any] else {
        return nil
    }
    return mdItemMetadata
}
