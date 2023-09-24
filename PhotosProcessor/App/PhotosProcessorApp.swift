//
//  PhotosProcessorApp.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

let configuration = Configuration.shared
let commandQueue = CommandQueue.share

@main
struct PhotosProcessorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands { SidebarCommands() }
    }
}
