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


    var activatorView: some View {
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
                    Text("You are using the full version of the app. Enjoy it!")
                        .font(.system(.footnote))
                        .foregroundColor(.secondary)
                } else {
                    Text("You are using the free version of the app. Please activate the app to use all the features.")
                        .font(.system(.footnote))
                        .foregroundColor(.secondary)
                }
                Toggle("", isOn: $config.activated)
                    .toggleStyle(.switch)
            }
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(8)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // VStack(alignment: .leading, spacing: 8) {
                //     activatorView
                // }
                // Divider()
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
                useSetting(
                    title: "Quickly Process Save Directory",
                    description: "The app will save the processed image to this directory.",
                    content: HStack {
                        TextField("Quickly Process Save Directory", text: $config.quicklyprocessSaveDirectory)
                            .textFieldStyle(.roundedBorder)
                            .disabled(true)
                        Button("Browse") {
                            InternalKit.useDirectoryPanel(
                                title: "Choose a directory",
                                message: "Choose a directory to save the processed image",
                                primaryButton: "OK",
                                secondaryButton: "Cancel"
                            ) { url in
                                if url != nil {
                                    config.quicklyprocessSaveDirectory = url!.path
                                }
                            }
                        }
                    }
                )
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

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    useSetting(
                        title: "Quickly Compression",
                        description: "Setup a keyboard shortcut to quickly compress the selected image.",
                        content: HStack {
                            KeyboardShortcuts.Recorder(for: .quicklyCompression)
                        }
                    )
                }

            }
            .padding()
        }
        .navigationTitle("App Configuration")
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
