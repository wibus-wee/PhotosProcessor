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
                    Label("Compressor", systemImage: "square.and.arrow.down")
                }
                useNavigationLink {
                    ModifyMetadataView()
                } label: {
                    Label("Metadata", systemImage: "tag.circle")
                }
            }

            Section("Misc") {
                NavigationLink {
                    SettingView()
                } label: {
                    Label("Setting", systemImage: "gear")
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
