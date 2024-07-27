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
            #if DEBUG
            Section("WIP") {
                useNavigationLink {
                    WaterMarkView()
                } label: {
                    Label("Watermark", systemImage: "drop.fill")
                }
                useNavigationLink {
                    ImageGPSLocationView()
                } label: {
                    Label("GPS Location", systemImage: "location.circle")
                }
            }
            Section("Planing") {
                // Stitching images
                useNavigationLink {
                    // ImageStitchingView()
                    WelcomeView()
                } label: {
                    Label("Stitching", systemImage: "slider.horizontal.below.square.and.square.filled")
                }
                // DAMA
                useNavigationLink {
                    // DAMAView()
                    WelcomeView()
                } label: {
                    Label("DAMA", systemImage: "bandage")
                }
                // Noise generator
                useNavigationLink {
                    // NoiseGeneratorView()
                    WelcomeView()
                } label: {
                    Label("Noise Generator", systemImage: "paintbrush")
                }
            }
            #endif
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
