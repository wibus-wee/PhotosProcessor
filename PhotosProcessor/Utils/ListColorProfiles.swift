//
//  ListColorProfiles.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import Foundation

func listColorProfiles() -> [String] {
    let fileManager = FileManager.default
    let profilesDirectoryURL = URL(fileURLWithPath: "/System/Library/ColorSync/Profiles")
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: profilesDirectoryURL, includingPropertiesForKeys: nil, options: [])
        let profileFileNames = fileURLs.map { $0.lastPathComponent }
        return profileFileNames
    } catch {
        print("Error listing Color Profiles: \(error)")
        return []
    }
}
