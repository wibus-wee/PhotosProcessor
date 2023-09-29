//
//  Configuration.swift
//  SoftwareHelper
//
//  Created by wibus on 2023/8/19.
//

import AppKit
import Combine
import LaunchAtLogin

// let documentDir = FileManager.default.homeDirectoryForCurrentUser

class Configuration: NSObject, ObservableObject {
    static let shared = Configuration()
    var cancellable: Set<AnyCancellable> = .init()
    
    override private init() {
        super.init()
        objectWillChange
            .sink { _ in
                self.save()
            }
            .store(in: &cancellable)
    }

    @PublishedStorage(key: "\(Constants.appKey).autostartup", defaultValue: false)
    var autostartup: Bool

    @PublishedStorage(key: "\(Constants.appKey).avifencLocationType", defaultValue: "built-in")
    var avifencLocationType: String

    @PublishedStorage(key: "\(Constants.appKey).avifencLocation", defaultValue: "")
    var avifencLocation: String

    @PublishedStorage(key: "\(Constants.appKey).metadata.saveAsNewFile", defaultValue: false)
    var metadataSaveAsNewFile: Bool // 是否将修改后的文件保存为新文件

    @PublishedStorage(key: "\(Constants.appKey).quicklyprocess.saveDirectory", defaultValue: "")
    var quicklyprocessSaveDirectory: String // 快速处理的保存目录

    public func switchAvifencLocation(_ value: String) {
        avifencLocation = value
        save()
    }

    public func switchAvifencLocationType(_ value: String) {
        avifencLocationType = value
        save()
    }

    @PublishedStorage(key: "\(Constants.appKey).executeImmediately", defaultValue: true)
    var executeImmediately: Bool
    
    public func switchAutoStartup(_ value: Bool) {
        autostartup = value
        if value {
            LaunchAtLogin.isEnabled = true
        } else {
            LaunchAtLogin.isEnabled = false
        }
        save()
    }
    
    public func save() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(saveNow), object: nil)
        perform(#selector(saveNow), with: nil, afterDelay: 1)
    }

    @objc func saveNow() {
        DispatchQueue.global().async {
            self._autostartup.saveFromSubjectValueImmediately()
        }
    }
    
}
