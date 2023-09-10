//
//  CompressImageView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct CompressImageView: View {
    @State private var selectedImage: Image?
    @State private var compressionQuality: CGFloat = 0.5

    var body: some View {
        VStack {
            selectedImage?
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Slider(value: $compressionQuality, in: 0.1...1.0, step: 0.1) {
                Text("压缩质量: \(Int(compressionQuality * 100))%")
            }

            Button("选择图片") {
                // 在这里实现选择图片的逻辑
            }

            Button("压缩图片") {
                // 在这里实现压缩图片的逻辑
            }
        }
    }
}

struct CompressImageView_Previews: PreviewProvider {
    static var previews: some View {
        CompressImageView()
    }
}
