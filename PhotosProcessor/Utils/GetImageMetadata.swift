//
//  GetImageMetadata.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import ImageIO
import SwiftUI

func getImageMetadata(image: NSImage) -> [String: Any]? {
    guard let imageData = image.tiffRepresentation else {
        return nil
    }
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
        return nil
    }
    guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
        return nil
    }
    return metadata
}

func getColorProfileFromMetadata(metadata: [String: Any]) -> String? {
    guard let colorProfile = metadata[kCGImagePropertyProfileName as String] as? String else {
        return nil
    }
    return colorProfile
}

// KMD
func getDateTimeOriginalFromMetadata(metadata: [String: Any]) -> String? {
    guard let dateTimeOriginal = metadata[kCGImagePropertyExifDateTimeOriginal as String] as? String else {
        return nil
    }
    return dateTimeOriginal
}