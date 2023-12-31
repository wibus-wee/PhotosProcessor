//
//  SelectedFile.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/29.
//


import Foundation
import SwiftUI

func getSelectedFileInFinder() -> (path: String, name: String)? {
    if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != "com.apple.finder" {
        return nil
    }
    let script = NSAppleScript(source: """
        tell application "Finder"
            set theFiles to selection
            set theFile to item 1 of theFiles as alias
            set theFile to POSIX path of theFile
        end tell
        """)
    var error: NSDictionary?
    let output: NSAppleEventDescriptor = script!.executeAndReturnError(&error)
    if (error != nil) {
        print("error: \(String(describing: error))")
        return nil
    }
    let path = output.stringValue!
    let name = path.components(separatedBy: "/").last!
    return (path, name)
}
