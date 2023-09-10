//
//  ModifyMetadataView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct ModifyMetadataView: View {
    @State private var selectedImage: Image?

    @State private var newMetadataKey: String = ""
    @State private var copyFromKey: String = ""

    var body: some View {
        VStack {
            selectedImage?
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            TextField("新元数据键名", text: $newMetadataKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("复制自键名", text: $copyFromKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("选择图片") {
                // 在这里实现选择图片的逻辑
            }

            Button("修改元数据") {
                // 在这里实现修改元数据的逻辑
            }
        }
    }
}

struct ModifyMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyMetadataView()
    }
}
