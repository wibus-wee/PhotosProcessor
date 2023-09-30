//
//  PhotosProcessorApp.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

let configuration = Configuration.shared
let commandQueue = CommandQueue.shared
let processImage = ProcessImage.shared

@main
struct PhotosProcessorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands { SidebarCommands() }
    }
}