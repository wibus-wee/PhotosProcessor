//
//  SidebarView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//


import SwiftUI

struct SidebarView: View {
    var body: some View {
        Group {
            useNavigationLink {
                WelcomeView()
            } label: {
                Label("Home", systemImage: "house")
            }

            Section("Features") {
                useNavigationLink {
                    CompressImageView()
                } label: {
                    // Label("压缩图片", systemImage: "arrow.down.circle")
                    Label("Compressor", systemImage: "square.and.arrow.down")
                }
                useNavigationLink {
                    ModifyMetadataView()
                } label: {
                    // Label("修改元数据", systemImage: "info.circle")
                    Label("Metadata", systemImage: "tag.circle")
                }
            }
        }
        .listStyle(SidebarListStyle())
    }

    func useNavigationLink(destination: @escaping () -> some View, label: () -> some View) -> some View {
        NavigationLink {
            destination().frame(minWidth: 400, minHeight: 200)
        } label: {
            label()
        }
    }
}
