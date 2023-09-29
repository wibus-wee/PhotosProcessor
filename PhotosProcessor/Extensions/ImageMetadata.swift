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
    let fileManager = FileManager.default
    
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
        if key.area.isEmpty {
            return metadata[key.key as String]
        }
        guard let area = metadata["{\(key.area)}"] as? [String: Any] else {
            return nil
        }
        return area[key.key as String]
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
    
    func editMetadata(key: MetadataKey, value: Any?) -> Bool {
        let url = self.url!
        let urlComponents = url.pathComponents
        let fileName = urlComponents[urlComponents.count - 1]
        let fileNameComponents = fileName.split(separator: ".")
        let fileExtension = fileNameComponents[fileNameComponents.count - 1]
        let newFileName = "\(fileNameComponents[0])_metadata_edited.\(fileExtension)"
        let newFilePath = url.deletingLastPathComponent().appendingPathComponent(newFileName)
        let newFileURL = URL(fileURLWithPath: newFilePath.path)
        
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
        let area: String? = key.area.isEmpty ? nil : "{\(key.area)}"
        let keyString = key.key
        
        if value == nil {
            if area == nil {
                newMetadata.removeValue(forKey: keyString as String)
            } else if var areaDict = newMetadata[area!] as? [String: Any] {
                areaDict[keyString as String] = nil
                newMetadata[area!] = areaDict
            }
        } else {
            if area == nil {
                newMetadata[keyString as String] = value
            } else {
                var areaDict = newMetadata[area!] as? [String: Any] ?? [String: Any]()
                areaDict[keyString as String] = value
                newMetadata[area!] = areaDict
            }
        }
        
        CGImageDestinationAddImage(imageDestination, image, newMetadata as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        
        var creationDate: Date
        var modificationDate: Date
        
        do {
            let attributes = try self.fileManager.attributesOfItem(atPath: url.path)
            creationDate = attributes[FileAttributeKey.creationDate] as! Date
            modificationDate = attributes[FileAttributeKey.modificationDate] as! Date
        } catch {
            print("[E] Bug occurred when edit metadata (read file attributes): \(error)")
            return false
        }
        
        // Replace file
        if !configuration.metadataSaveAsNewFile {
            do {
                try self.fileManager.removeItem(at: url)
                try self.fileManager.moveItem(at: newFileURL, to: url)
            } catch {
                print("[E] Bug occurred when edit metadata (replace file): \(error)")
                return false
            }
        }
        
        // Sync file date
        let syncPath = configuration.metadataSaveAsNewFile ? newFilePath.path : url.path
        let sync = syncImageDate(path: syncPath, original: creationDate, digitized: modificationDate)
        if !sync {
            print("[E] Bug occurred when edit metadata (sync file date)")
            return false
        }
        
        return true
    }
    
    func copyMetadata(from: MetadataKey, to: MetadataKey) -> Bool {
        let value = self.getMetadata(key: from)
        if (value == nil) {
            return false
        }
        return self.editMetadata(key: to, value: value!)
    }
    
    func removeMetadata(key: MetadataKey) -> Bool {
        return self.editMetadata(key: key, value: nil)
    }
    
    func addMetadata(key: MetadataKey, value: Any) -> Bool {
        return self.editMetadata(key: key, value: value)
    }
    
    func syncImageDate(path: String, original: Date? = nil, digitized: Date? = nil) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        print("[I] Sync image date: path=\(path), original=\(original?.description ?? "nil"), digitized=\(digitized?.description ?? "nil")")
        let ExifDateTimeOriginal = self.getMetadata(key: MetadataKey(key: kCGImagePropertyExifDateTimeOriginal, area: "Exif"))
        let ExifDateTimeDigitized = self.getMetadata(key: MetadataKey(key: kCGImagePropertyExifDateTimeDigitized, area: "Exif"))
        
        let DateTimeOriginal = original ?? dateFormatter.date(from: ExifDateTimeOriginal as! String)
        let DateTimeDigitized = digitized ?? dateFormatter.date(from: ExifDateTimeDigitized as! String)
        print("[I] Sync image date: DateTimeOriginal=\(DateTimeOriginal?.description ?? "nil"), DateTimeDigitized=\(DateTimeDigitized?.description ?? "nil")")
        
        var updatedAttributes: [FileAttributeKey: Any] = [:]
        
        if DateTimeOriginal != nil {
            updatedAttributes[FileAttributeKey.creationDate] = DateTimeOriginal
            print("[I] Sync image date: DateTimeOriginal=\(String(describing: DateTimeOriginal))")
        } else {
            print("[W] Sync image date: Formatted/Raw DateTimeOriginal is nil. DateTimeOriginal=\(DateTimeOriginal?.description ?? "nil")")
        }
        
        if DateTimeDigitized != nil {
            updatedAttributes[FileAttributeKey.modificationDate] = DateTimeDigitized
            print("[I] Sync image date: DateTimeDigitized=\(String(describing: DateTimeDigitized))")
        } else {
            print("[W] Sync image date: Formatted/Raw DateTimeDigitized is nil. DateTimeDigitized=\(DateTimeDigitized?.description ?? "nil")")
        }
        
        do {
            try self.fileManager.setAttributes(updatedAttributes, ofItemAtPath: path)
            return true
        } catch {
            print("[E] Bug occurred when sync image date: \(error)")
            return false
        }
    }
    
}
