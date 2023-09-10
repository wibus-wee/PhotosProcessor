import SwiftUI

struct CompressImageView: View {
    var availableColorProfiles: [String] = listColorProfiles()
    @State private var selectedImage: Image?
    @State private var compressionQuality: CGFloat = 0.85
    @State private var compressionSpeed: CGFloat = 0.0 // 0.0 表示最慢
    @State private var selectedYUVOption = 2 // 默认选择 YUV 4:2:0
    @State private var useColorProfiles = true
    @State private var cleanExifInfo = true
    @State private var selectedColorProfile: String = "sRGB Profile.icc"
    
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
        HStack {
            // 左侧：显示图片的预览和选择图片的功能
            VStack {
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("选择图片")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(width: 200, height: 200)
                        .background(Color.secondary.opacity(0.2))
                }
                
                Button("选择图片") {
                    // 在这里实现选择图片的逻辑
                }
            }
            .padding()
            
            // 右侧：设置项
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
                    .foregroundColor(.gray) // 使用黄色文本颜色
                
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

                
                Button("压缩图片") {
                    // 在这里实现压缩图片的逻辑
                }
                
            }
            .padding()
        }
    }
}
