//
//  ContentView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct ContentView: View {
    @StateObject var processimg = ProcessImage.shared
    
    init() {
        let url = URL(fileURLWithPath: "/System/Library/ColorSync/Profiles")
        let _ = url.startAccessingSecurityScopedResource()
    }
    
    var body: some View {
        NavigationView {
            List {
                SidebarView()
            }
            .listStyle(.sidebar)
            .navigationTitle(Constants.appName)
            WelcomeView()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)),
                        with: nil
                    )
                } label: {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }
            }

            ToolbarItem {
                Button {
                    processimg.reset()
                } label: {
                    Label("reset image", systemImage: "trash")
                }
                .disabled(!processimg.inited)
            }

            ToolbarItem {
                Button {
                    processimg.setup()
                } label: {
                    Label("setup image", systemImage: "photo")
                }
            }
        }
    }
}
