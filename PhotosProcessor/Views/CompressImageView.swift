//
//  CompressImageView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct CompressImageView: View {
    @State private var isStatusPopoverShown = false
    @State var showingLogSheetID = ""
    
    @State private var selectedImage: NSImage?
    @State private var selectedImagePath: String?
    @State private var selectedImageName: String = ""
    @State private var selectedImageMetadata: [String: Any]?
    
    @State private var queueId: UUID?
    
    @State private var compressionQuality: CGFloat = 0.85
    @State private var compressionSpeed: CGFloat = 0.0
    @State private var selectedYUVOption = 2
    @State private var useColorProfiles = true
    @State private var cleanExifInfo = true
    @State private var selectedColorProfile: String = "Follow Original"
    var availableColorProfiles: [String] = listColorProfiles() + ["Follow Original"]
    
    @State var isShowingLogSheet = false
    @StateObject private var executor = Executor()
    
    var yuvOptions = ["YUV 4:4:4", "YUV 4:2:2", "YUV 4:2:0", "YUV 4:0:0"]
    
    var yuvExplanation: String {
        switch selectedYUVOption {
        case 0:
            // return "YUV 4:4:4 提供最高质量但文件较大。"
            return "YUV 4:4:4 provides the highest quality but the file is large."
        case 1:
            // return "YUV 4:2:2 提供较高质量和适度的文件大小。"
            return "YUV 4:2:2 provides higher quality and moderate file size."
        case 2:
            // return "YUV 4:2:0 提供较小的文件大小，但可能会丧失一些图像细节。"
            return "YUV 4:2:0 provides a smaller file size, but may lose some image details."
        case 3:
            // return "YUV 4:0:0 去除色度信息，文件最小，但丧失颜色。"
            return "YUV 4:0:0 removes chroma information, the file is the smallest, but the color is lost."
        default:
            return ""
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if geometry.size.width > 600 {
                    HStack {
                        leftColumn
                        rightColumn
                    }
                } else {
                    ScrollView {
                        VStack {
                            leftColumn
                            rightColumn
                        }
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: {
                showingLogSheetID != ""
            },
            set: { newValue in
                if !newValue {
                    showingLogSheetID = ""
                }
            }
        )) {
            LogView(id: $showingLogSheetID)
        }
        .navigationTitle("Compress Image")
        .toolbar {
            Group {
                ToolbarItem {
                    Button {
                        InternalKit.useFilePanel(title: "Choose Image", message: "Select the image file to compress", action: { url in
                            if let selectedURL = url {
                                selectedImage = NSImage(contentsOf: selectedURL)
                                selectedImagePath = selectedURL.path
                                selectedImageName = selectedURL.lastPathComponent
                                selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                queueId = nil
                            }
                        })
                    } label: {
                        Label("Choose Image", systemImage: "photo")
                    }
                    .help("Choose Image")
                }
                ToolbarItem {
                    Button {
                        if selectedImage != nil {
                            let config = CompressorConfig(
                                quality: Int(compressionQuality * 100),
                                yuv: yuvOptions[selectedYUVOption].replacingOccurrences(of: "YUV ", with: "").replacingOccurrences(of: ":", with: ""),
                                speed: Int(compressionSpeed * 100),
                                cleanExifInfo: cleanExifInfo,
                                useColorProfiles: useColorProfiles,
                                colorProfile: selectedColorProfile == "Follow Original" ? nil : selectedColorProfile
                            )
                            let compressor = Compressor()
                            let compressCommand = compressor.avifencCommand(imagePath: selectedImagePath!, config: config)
                            if compressCommand == nil {
                                return
                            }
                            // let id = commandQueue.enqueueBeta(compressCommand!.command, compressCommand!.arguments, parentId: nil, description: "Compress \(selectedImageName) to AVIF")
                            let id = commandQueue.enqueue(compressCommand!.command, compressCommand!.arguments, description: "Compress \(selectedImageName) to AVIF")
                            queueId = id
                            // Configuration: Execute command immediately
                            if configuration.executeImmediately {
                                commandQueue.execute(id: id)
                            }
                            // sendNotification(title: "\(selectedImageName) compressing", subtitle: "AVIF", informativeText: "Compressing \(selectedImageName) to AVIF")
                        }
                    } label: {
                        if queueId != nil {
                            Label("Start Compressing", systemImage: "play.fill")
                        } else {
                            Label("Start Compressing", systemImage: "play")
                        }
                    }
                    .disabled(selectedImage == nil || queueId != nil)
                }
                ToolbarItem {
                    Button {
                        self.isStatusPopoverShown.toggle()
                    } label: {
                        Label("Queue", systemImage: "list.bullet.rectangle")
                    }
                    .popover(isPresented: self.$isStatusPopoverShown, arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("Commands List")
                            Text("There are \(commandQueue.commands.count) commands in the queue.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            ForEach(commandQueue.commands, id: \.id) { command in
                                Divider()
                                VStack {
                                    Text("\(command.description)")
                                        .font(.system(.body, design: .rounded))
                                    Text("\(command.id)")
                                        .foregroundColor(.secondary)
                                        .font(.system(.caption, design: .monospaced))
                                    List {
                                        ForEach(command.children, id: \.self) { childId in
                                            let childCommand = commandQueue.commands.first(where: { $0.id == childId })!
                                            Text("\(childCommand.description) (Child)")
                                                .font(.system(.body, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    
                                    HStack {
                                        Button("Execute") {
                                            commandQueue.execute(id: command.id)
                                            isStatusPopoverShown = false
                                        }
                                        .buttonStyle(.borderedProminent)
                                        Button("Cancel") {
                                            commandQueue.cancel(id: command.id)
                                            isStatusPopoverShown = false
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            ForEach(commandQueue.commandResults, id: \.id) { commandResult in
                                Divider()
                                VStack {
                                    Text("\(commandResult.info.description)")
                                        .font(.system(.body, design: .rounded))
                                    Text("\(commandResult.id) (Executed)")
                                        .foregroundColor(.secondary)
                                        .font(.system(.caption, design: .monospaced))
                                    Spacer()
                                    
                                    HStack {
                                        Button("Show Log") {
                                            showingLogSheetID = commandResult.id.uuidString
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                            
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    var leftColumn: some View {
        VStack {
            if let image = selectedImage {
                VStack {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .cornerRadius(8)
                        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                    if let url = object {
                                        selectedImage = NSImage(contentsOf: url)
                                        selectedImagePath = url.path
                                        selectedImageName = url.lastPathComponent
                                        selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                        queueId = nil
                                    }
                                }
                                return true
                            }
                            return false
                        }
                }
                
            } else {
                Text("Choose Image")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(width: 300, height: 300)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(8)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    selectedImage = NSImage(contentsOf: url)
                                    selectedImagePath = url.path
                                    selectedImageName = url.lastPathComponent
                                    selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                    queueId = nil
                                }
                            }
                            return true
                        }
                        return false
                    }
                
            }
            Divider()
            VStack() {
                Text("\(selectedImageName == "" ? "No Image Selected" : selectedImageName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Size: \(Int(selectedImage?.size.width ?? 0)) x \(Int(selectedImage?.size.height ?? 0))")
                    .font(.caption)
                    .foregroundColor(.gray)
                if let metadata = selectedImageMetadata {
                    if let profileName = getColorProfileFromMetadata(metadata: metadata) {
                        Text("Color Profile: \(profileName)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Color Profile: Unknown")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
        }
        .padding()
    }
    
    var rightColumn: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Slider(value: $compressionQuality, in: 0.0...1.0, step: 0.05) {
                    Text("Quality: \(Int(compressionQuality * 100))%")
                }
                Text("Color Quality and Alpha Quality will be adjusted at the same time")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Slider(value: $compressionSpeed, in: 0.0...1.0, step: 0.05) {
                    Text("Speed: \(Int(compressionSpeed * 100))%")
                }
                Text("Control the speed and efficiency of image encoding (0% slowest)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Picker("YUV Sampling", selection: $selectedYUVOption) {
                ForEach(0..<yuvOptions.count) {
                    Text(yuvOptions[$0])
                }
            }
            
            Text(yuvExplanation)
                .font(.caption)
                .foregroundColor(.gray)
            
            Toggle("Clean EXIF Info", isOn: $cleanExifInfo)
            Text("Clean EXIF will also clear the Color Profiles, which may cause the image to not be displayed.")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Toggle("Color Profiles 覆盖", isOn: $useColorProfiles)
            Toggle("Color Profiles Override", isOn: $useColorProfiles)
            if cleanExifInfo && !useColorProfiles {
                // Text("建议勾选此项，防止图片无法正常显示")
                Text("It is recommended to check this option to prevent the image from not being displayed normally")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            // Picker("选择 Color Profile", selection: $selectedColorProfile) {
            Picker("Select Color Profile", selection: $selectedColorProfile) {
                ForEach(availableColorProfiles, id: \.self) { profile in
                    Text(profile)
                }
            }
            .disabled(!useColorProfiles)
            // Text("使用 Follow Original 将会始终恢复原始的 Color Profile, 但当系统内无此 Color Profile 时, 将会使用 sRGB")
            Text("Using Follow Original will always restore the original Color Profile, but when there is no such Color Profile in the system, sRGB will be used")
                .font(.caption)
                .foregroundColor(.gray)
            
        }
        .padding()
    }
}
