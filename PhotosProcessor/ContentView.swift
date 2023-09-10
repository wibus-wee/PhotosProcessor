//
//  ContentView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedView: String?

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CompressImageView(),
                    tag: "compress",
                    selection: $selectedView
                ) {
                    Label("压缩图片", systemImage: "arrow.down.circle")
                }

                NavigationLink(
                    destination: ModifyMetadataView(),
                    tag: "modifyMetadata",
                    selection: $selectedView
                ) {
                    Label("修改元数据", systemImage: "info.circle")
                }
            }
            .listStyle(SidebarListStyle())

            Text("选择一个功能")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.secondary.opacity(0.2))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
