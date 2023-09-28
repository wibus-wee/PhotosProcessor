//
//  SettingView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject var config = configuration
    
    func useSetting(title: String, description: String, content: some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(.headline))
                Spacer()
                content
            }
            Text(description)
                .font(.system(.footnote))
                .foregroundColor(.secondary)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 8) {
                    // Text("Basic Setting") 
                    //     .font(.system(.title2, design: .rounded, weight: .thin))
                    // Text("The basic setting of the app.")
                    //     .font(.system(.footnote))
                    //     .foregroundColor(.secondary)

                    useSetting(
                        title: "Auto Startup",
                        description: "Auto Startup means the app will start automatically when you log in.",
                        content: Toggle("", isOn: $config.autostartup)
                            .toggleStyle(.switch)
                            .onChange(of: config.autostartup) { value in
                                config.switchAutoStartup(value)
                            }
                    )
                }

                Divider()
                

                VStack(alignment: .leading, spacing: 8) {
                    // Text("Compression Setting")
                    //     .font(.system(.title2, design: .rounded, weight: .thin))
                    // Text("The compression feature setting of the app.")
                    //     .font(.system(.footnote))
                    //     .foregroundColor(.secondary)
                    useSetting(
                    title: "Execute Immediately",
                    description: "The app will start processing immediately when you add it into Commands List",
                    content: Toggle("", isOn: $config.executeImmediately)
                        .toggleStyle(.switch)
                )

                useSetting(
                    title: "Avifenc Executable Location Type",
                    description: "Built-in means the app will use the built-in avifenc binary file. Custom means the app will use the avifenc binary file you specified.",
                    content: Picker("", selection: $config.avifencLocationType) {
                        Text("Built-in").tag("built-in")
                        Text("Custom").tag("custom")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .onChange(of: config.avifencLocationType) { value in
                        config.switchAvifencLocationType(value)
                    }
                )
                if config.avifencLocationType == "custom" {
                    useSetting(
                        title: "Avifenc Executable Location",
                        description: "The app will use the avifenc binary file you specified.",
                        content: HStack {
                            TextField("Avifenc Executable Location", text: $config.avifencLocation)
                                .textFieldStyle(.roundedBorder)
                            Button("Browse") {
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

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    // Text("Metadata Setting")
                    //     .font(.system(.title2, design: .rounded, weight: .thin))
                    // Text("The metadata feature setting of the app.")
                    //     .font(.system(.footnote))
                    //     .foregroundColor(.secondary)
                    useSetting(
                        title: "Save As New File",
                        description: "Save As New File means the app will save the modified file as a new file.",
                        content: Toggle("", isOn: $config.metadataSaveAsNewFile)
                            .toggleStyle(.switch)
                    )
                }

            }
            .padding()
        }
        .navigationTitle("App Configuration")
    }
}
