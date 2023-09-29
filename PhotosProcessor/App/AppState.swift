//
//  AppState.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/29.
//

import SwiftUI
import KeyboardShortcuts
import UniformTypeIdentifiers

@MainActor
class AppState: ObservableObject {
    private func isImage(path: String) -> Bool {
        let fileURL = URL(fileURLWithPath: path)
        let typeIdentifier = try? fileURL.resourceValues(forKeys: [.typeIdentifierKey])
        if typeIdentifier == nil {
            print("[*] failed to get file type")
            return false
        }
        if !UTType((typeIdentifier?.typeIdentifier)!)!.conforms(to: .image) {
            print("[*] selected file is not image")
            return false
        }
        return true
    }
    init() {
        registQuicklyCompressionKeyboardShortcutAction()
    }
    
    func registQuicklyCompressionKeyboardShortcutAction() {
        KeyboardShortcuts.onKeyUp(for: .quicklyCompression) {
            print("[*] Quickly Compression")
            var path: String? = nil
            var name: String? = nil
            var type = "Finder" // Finder, Pasteboard
            if let file = getSelectedFileInFinder() {
                print("[*] get file from Finder")
                // 读取文件的类型
                if !self.isImage(path: file.path) {
                    return
                }
                path = file.path
                name = file.name
                type = "Finder"
            } else {
                print("[*] no selected file in Finder")
                print("[*] get file from Pasteboard")
                let pasteboard = NSPasteboard.general
                //  let files = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL]
                // 把黏贴板的图片保存到临时文件夹
                let files = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage]
                if files == nil || files!.count == 0 {
                    print("[*] no image in pasteboard")
                    return
                }
                let uuid = UUID().uuidString
                let file = files![0]
                let data = file.tiffRepresentation
                let imageRep = NSBitmapImageRep(data: data!)
                let imageData = imageRep!.representation(using: .jpeg, properties: [:])
                let tempPath = NSTemporaryDirectory() + "temp_\(uuid).jpeg"
                let url = URL(fileURLWithPath: tempPath)
                do {
                    try imageData?.write(to: url)
                } catch {
                    print(error)
                }
                path = tempPath
                name = "temp_\(uuid).jpeg"
                type = "Pasteboard"
            }
            print("[*] \(String(describing: path)), \(String(describing: name))")
            if path == nil || name == nil {
                return
            }
            sendNotification(title: "Quickly Compression", body: "Compressing \(name!) from \(type)", delayInSeconds: 0.5)
            let saveDirectory = configuration.quicklyprocessSaveDirectory
            let config = CompressorConfig(
                quality: Int(0.85 * 100),
                yuv: "420",
                speed: Int(0.05 * 100),
                arguments: nil,
                output: saveDirectory
            )
            
            let compressor = Compressor()
            _ = compressor.compress(
                path: path!,
                name: name!,
                config: config
            )
        }
    }
}
