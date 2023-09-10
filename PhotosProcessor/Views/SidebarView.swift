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
            Section("Basic") {
                useNavigationLink {
                    WelcomeView()
                } label: {
                    Label("Home", systemImage: "house")
                }
            }
        }
    }
    
    func useNavigationLink(destination: @escaping () -> some View, label: () -> some View) -> some View {
        NavigationLink {
            destination().frame(minWidth: 400, minHeight: 200)
        } label: {
            label()
        }
    }
}
