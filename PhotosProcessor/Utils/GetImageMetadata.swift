//
//  GetImageMetadata.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import ImageIO
import SwiftUI

func getImageMetadata(image: NSImage) -> [String: Any]? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return nil
    }
    
    let source = CGImageSourceCreateWithDataProvider(cgImage.dataProvider!, nil)
    
    guard let imageSource = source else {
        return nil
    }
    
    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any]
    
    return imageProperties
}

func getColorProfileFromMetadata(metadata: [String: Any]) -> String? {
    if let profileName = metadata[kCGImagePropertyProfileName as String] as? String {
        return profileName
    }
    return nil
}
