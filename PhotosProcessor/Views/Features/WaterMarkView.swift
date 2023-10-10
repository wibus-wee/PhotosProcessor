//
//  WaterMarkView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct WaterMarkView: View {
    
    @State private var watermarkText: String = ""
    @State private var watermarkFontSize: String = ""
    
    let watermark = Watermark()
    
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
        .navigationTitle("Watermark")
        .toolbar {
            Group {
                ToolbarItem {
                    Button {
                        if processImage.image != nil {
                            let processedUrl = watermark.addWatermark(processImage.image!, text: watermarkText)
                                processImage.setup(url: processedUrl)
                                    // InternalKit.saveFilePanel(title: "Save Image", message: "Select the location to save the compressed image", action: { url in
                                    //     if let saveLocationURL = url {
                                    //         do {
                                    //             try FileManager.default.copyItem(at: processedUrl, to: saveLocationURL)
                                    //             print("[I] Saved image to \(saveLocationURL)")
                                    //         } catch {
                                    //             print("[E] Failed to save image to \(saveLocationURL)")
                                    //         }
                                    //     }
                                    // })
                        }
                    } label: {
                        Label("Save Image", systemImage: "square.and.arrow.down")
                    }
                    .help("Save Image")
                }
                ToolbarItem {
                    Button {
                        if processImage.image != nil {
                            let image = watermark.visibleWatermark(processImage.image!)
                            
                            print("[*] \(image)")
                        }
                    } label: {
                        Label("Visible Watermark", systemImage: "eye")
                    }
                    .help("Show Watermark")
                }
            }
        }
    }
    
    var leftColumn: some View {
        ImageUniversalView()
    }
    
    var rightColumn: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Watermark Text")
                    .font(.headline)
                    .foregroundColor(.gray)
                TextField("Watermark Text", text: $watermarkText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 8)
                
                Text("Watermark Font Size")
                    .font(.headline)
                    .foregroundColor(.gray)
                TextField("Watermark Font Size", text: $watermarkFontSize)
            }
        }
    }
}
