//
//  Watermark.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

class Watermark {

    func visibleWatermark(_ image: NSImage) -> Any {
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let text = extractText(bitmap)
        return text.fromBinary()
    }

    func addWatermark(_ image: NSImage, text: String) -> URL {
       
    }
}