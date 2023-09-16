import SwiftUI

struct CompressImageView: View {
    @State private var selectedImage: NSImage?
    @State private var selectedImagePath: String?
    @State private var selectedImageMetadata: [String: Any]?
    @State private var compressionQuality: CGFloat = 0.85
    @State private var compressionSpeed: CGFloat = 0.0 // 0.0 表示最慢
    @State private var selectedYUVOption = 2 // 默认选择 YUV 4:2:0
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
            return "YUV 4:4:4 提供最高质量但文件较大。"
        case 1:
            return "YUV 4:2:2 提供较高质量和适度的文件大小。"
        case 2:
            return "YUV 4:2:0 提供较小的文件大小，但可能会丧失一些图像细节。"
        case 3:
            return "YUV 4:0:0 去除色度信息，文件最小，但丧失颜色。"
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
        .navigationTitle("图片压缩")
        .toolbar {
            Group {
                ToolbarItem {
                    Button {
                        InternalKit.useFilePanel(title: "选择图片", message: "请选择要压缩的图片文件", action: { url in
                            if let selectedURL = url {
                                selectedImage = NSImage(contentsOf: selectedURL)
                                selectedImagePath = selectedURL.path
                            }
                            selectedImageMetadata = getImageMetadata(image: selectedImage!)
                        })
                    } label: {
                        Label("选择图片", systemImage: "photo")
                    }
                    .help("选择图片")
                }
                ToolbarItem {
                    Button {
                        if let image = selectedImage {
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
                            isShowingLogSheet.toggle()
                            executor.clean()
                            executor.executeAsync(compressCommand!.command, compressCommand!.arguments)
                        }
                    } label: {
                        Label("保存图片", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingLogSheet) {
            LogView(outputText: $executor.outputText, errorMessage: $executor.errorMessage, isRunning: $executor.isRunning)
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
                    
                    Divider()
                    VStack() {
                        Text("Name: \(image.name() ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Size: \(Int(image.size.width)) x \(Int(image.size.height))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        //selectedImageMetadata: [String: Any]?
                        if let metadata = selectedImageMetadata {
                            if let profileName = getColorProfileFromMetadata(metadata: metadata) {
                                Text("Color Profile: \(profileName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    }
                }
               
            } else {
                Text("选择图片")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(width: 300, height: 300)
                    .background(Color.secondary.opacity(0.2))
            }
        }
        .padding()
    }
    
    var rightColumn: some View {
        VStack(alignment: .leading) {
            Slider(value: $compressionQuality, in: 0.0...1.0, step: 0.05) {
                Text("质量: \(Int(compressionQuality * 100))%")
                Text("将会同时调整 Color Quality 与 Alpha Quality")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Slider(value: $compressionSpeed, in: 0.0...1.0, step: 0.05) {
                Text("压缩速度: \(Int(compressionSpeed * 100))%")
                Text("控制图像编码的速度和效率 (0% 最慢)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Picker("YUV采样方式", selection: $selectedYUVOption) {
                ForEach(0..<yuvOptions.count) {
                    Text(yuvOptions[$0])
                }
            }
            
            Text(yuvExplanation)
                .font(.caption)
                .foregroundColor(.gray)
            
            Toggle("清除 EXIF 信息", isOn: $cleanExifInfo)
            Text("清除 EXIF 会同时将 Color Profiles 清除，有可能导致图片无法显示。")
                .font(.caption)
                .foregroundColor(.gray)
            
            Toggle("Color Profiles 覆盖", isOn: $useColorProfiles)
            if cleanExifInfo && !useColorProfiles {
                Text("建议勾选此项，防止图片无法正常显示")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Picker("选择 Color Profile", selection: $selectedColorProfile) {
                ForEach(availableColorProfiles, id: \.self) { profile in
                    Text(profile)
                }
            }
            .disabled(!useColorProfiles)
            Text("使用 Follow Original 将会始终恢复原始的 Color Profile, 但当系统内无此 Color Profile 时, 将会使用 sRGB")
                .font(.caption)
                .foregroundColor(.gray)
            
        }
        .padding()
    }
}
