//
//  SettingView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI
import KeyboardShortcuts
struct SettingView: View {
    @StateObject var config = configuration
    
    @State private var quicklyProcessSaveDirectoryOptions: [String] = []
    @State private var avifencLocationOptions: [String] = []
    
    init() {
        _quicklyProcessSaveDirectoryOptions = State(initialValue: [config.quicklyprocessSaveDirectory] + ["Others"])
        _avifencLocationOptions = State(initialValue: [config.avifencLocation] + ["Others"])
    }
    
    private enum Tabs: Hashable {
        case general
        case compression
        case metadata
        case watermark
        case gpslocation
        case activate
    }
    
    /// A helper function to create a setting view.
    /// - Parameters:
    ///  - title: The title of the setting.
    /// - description(DEPRECATED): The description of the setting.(It will be removed in the future.)
    /// - content: The content of the setting.
    /// - Returns: A setting view.
    private func useSetting(title: String, description: String? = nil, content: some View) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 16) {
            Text(title)
                .frame(width: 200, alignment: .trailing)
            content
                .frame(width: 200, alignment: .leading)
        }
        .padding(.vertical, 4)
        // .frame(width: 200)
    }
    
    var body: some View {
        
        return TabView {
            generalView
            compressionView
            metadataView
            watermarkView
            gpslocationView
            activateView
        }
        .frame(width: 700)
    }
    
    var generalView: some View {
        Form {
            VStack(alignment: .center) {
                useSetting(
                    title: "Startup:",
                    description: "The app will start automatically when you log in.",
                    content: Toggle("Start at login", isOn: $config.autostartup)
                        .onChange(of: config.autostartup) { value in
                            config.switchAutoStartup(value)
                        }
                )
                useSetting(
                    title: "Save as new file",
                    description: "Save As New File means the app will save the modified file as a new file.",
                    content: Toggle("Save as new file", isOn: $config.saveAsNewFile)
                )
                
                Divider()
                
                
                
                useSetting(
                    title: "Quickly Process save directory:",
                    description: "The app will save the processed image to this directory.",
                    content: Picker("", selection: $config.quicklyprocessSaveDirectory) {
                        ForEach(quicklyProcessSaveDirectoryOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                        .onChange(of: config.quicklyprocessSaveDirectory) { value in
                            if value == "Others" {
                                InternalKit.useDirectoryPanel(
                                    title: "Choose a directory",
                                    message: "Choose a directory to save the processed image",
                                    primaryButton: "OK",
                                    secondaryButton: "Cancel"
                                ) { url in
                                    if url != nil {
                                        config.quicklyprocessSaveDirectory = url!.path
                                        quicklyProcessSaveDirectoryOptions = [config.quicklyprocessSaveDirectory] + ["Others"]
                                    }
                                }
                            }
                        }
                    
                )
                
                Divider()
                
                useSetting(
                    title: "Quickly Compression:",
                    description: "Setup a keyboard shortcut to quickly compress the selected image.",
                    content: KeyboardShortcuts.Recorder(for: .quicklyCompression)
                )
            }
        }
        .padding(20)
        .tabItem {
            Label("General", systemImage: "gear")
        }
        .tag(Tabs.general)
    }
    
    var compressionView: some View {
        Form {
            VStack(alignment: .center) {
                useSetting(
                title: "Execute immediately",
                description: "The app will start processing immediately when you add it into Commands List",
                content: Toggle("Execute immediately", isOn: $config.executeImmediately)
            )
            useSetting(
                title: "Executable Location type",
                description: "Built-in means the app will use the built-in avifenc binary file. Custom means the app will use the avifenc binary file you specified.",
                content: Picker("", selection: $config.avifencLocationType) {
                    Text("Built-in").tag("built-in")
                    Text("Custom").tag("custom")
                }
                    .onChange(of: config.avifencLocationType) { value in
                        config.switchAvifencLocationType(value)
                    }
            )
                useSetting(
                    title: "Executable Avifenc location",
                    description: "The app will use the avifenc binary file you specified.",
                    content: Picker("", selection: $config.avifencLocation) {
                        ForEach(avifencLocationOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                        .disabled(config.avifencLocationType == "built-in")
                        .onChange(of: config.avifencLocation) { value in
                            if value == "Others" {
                                let dialog = NSOpenPanel()
                                dialog.title = "Choose a avifenc binary file"
                                dialog.showsResizeIndicator = true
                                dialog.showsHiddenFiles = false
                                dialog.canChooseDirectories = false
                                dialog.canCreateDirectories = false
                                dialog.allowsMultipleSelection = false
                                dialog.allowedContentTypes = [.executable]
                                if dialog.runModal() == NSApplication.ModalResponse.OK {
                                    let result = dialog.url
                                    if (result != nil) {
                                        let path = result!.path
                                        config.switchAvifencLocation(path)
                                    }
                                } else {
                                    return
                                }
                            }
                        }
                )
            }
        }
        .padding(20)
        .tabItem {
            Label("Compression", systemImage: "square.and.arrow.down")
        }
        .tag(Tabs.compression)
    }
    
    var metadataView: some View {
        Form {
            VStack(alignment: .center) {
                Text("Setting for metadata is not available now.")
            }
        }
        .padding(20)
        .tabItem {
            Label("Metadata", systemImage: "tag.circle")
        }
        .tag(Tabs.metadata)
    }
    var watermarkView: some View {
        Form {
            VStack(alignment: .center) {
                Text("Setting for watermark is not available now.")
            }
        }
        .padding(20)
        .tabItem {
            Label("Watermark", systemImage: "drop.fill")
        }
        .tag(Tabs.watermark)
    }
    var gpslocationView: some View {
        Form {
            VStack(alignment: .center) {
               Text("Setting for GPS Location is not available now.")
            }
        }
        .padding(20)
        .tabItem {
            Label("GPS Location", systemImage: "location.circle")
        }
        .tag(Tabs.gpslocation)
    }
    
    var activateView: some View {
        Form {
            VStack(alignment: .center) {
                HStack(alignment: .top, spacing: 16) {
                    VStack {
                        Image("Avatar")
                            .resizable()
                            .frame(width: 64, height: 64)
                    }
                    VStack(alignment: .leading) {
                        Text("Activate the app")
                                .font(.system(.headline))
                        if config.activated {
                            Text("You are using the full version of the app. Enjoy the full features!")
                                .font(.system(.footnote))
                                .foregroundColor(.secondary)
                        } else {
                            Text("You are using the free version of the app. Limited features are available.")
                                .font(.system(.footnote))
                                .foregroundColor(.secondary)
                        }
                        Toggle("", isOn: $config.activated)
                            .toggleStyle(.switch)
                    }
                }
                .frame(maxWidth: 500)
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(8)
                
                Divider()

                useSetting(
                    title: "Activate Email",
                    description: "",
                    content: SecureField("", text: .constant("i@wibus.ren"))
                        .disabled(true)
                )

                useSetting(
                    title: "Activate Code",
                    description: "",
                    content: TextField("", text: .constant("i@wibus.ren"))
                        .disabled(true)
                )

                Button("Activate") {
                        
                }
            }
        }
        .padding(20)
        .tabItem {
            Label("Activate", systemImage: "sparkles.rectangle.stack")
        }
        .tag(Tabs.activate)
    }
}

// struct SettingView_Previews: PreviewProvider {
//     static var previews: some View {
//         SettingView()
//     }
// }
