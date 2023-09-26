//
//  WaterMarkView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct WaterMarkView: View {
    @State private var selectedImage: NSImage? = nil {
        didSet {
            if selectedImage == nil {
                selectedImagePath = ""
                selectedImageName = ""
                selectedImageMetadata = nil
            }
        }
    }
    @State private var selectedImagePath: String?
    @State private var selectedImageName: String?
    @State private var selectedImageMetadata: ImageMetadata?
    
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
                        InternalKit.useFilePanel(title: "Choose Image", message: "Select the image file to compress", action: { url in
                            if let selectedURL = url {
                                selectedImage = NSImage(contentsOf: selectedURL)
                                selectedImagePath = selectedURL.path
                                selectedImageName = selectedURL.lastPathComponent
                                selectedImageMetadata = ImageMetadata(url: selectedURL)
                            }
                        })
                    } label: {
                        Label("Choose Image", systemImage: "photo")
                    }
                    .help("Choose Image")
                }
                ToolbarItem {
                    Button {
                        if selectedImage != nil {
                            let image = watermark.addWatermark(selectedImage!, text: watermarkText) { image in
                                if let image = image {
                                    selectedImage = image
                                    InternalKit.saveFilePanel(title: "Save Image", message: "Select the location to save the compressed image", action: { url in
                                        if let selectedURL = url {
                                            let data = image.tiffRepresentation
                                            let bitmap = NSBitmapImageRep(data: data!)
                                            let jpeg = bitmap?.representation(using: .jpeg, properties: [:])
                                            try? jpeg?.write(to: selectedURL)
                                        }
                                    })
                                }
                            }
                        }
                    } label: {
                        Label("Save Image", systemImage: "square.and.arrow.down")
                    }
                    .help("Save Image")
                }
                ToolbarItem {
                    Button {
                        if selectedImage != nil {
                            let image = watermark.visibleWatermark(selectedImage!)
                            selectedImage = image
                            InternalKit.saveFilePanel(title: "Save Image", message: "Select the location to save the compressed image", action: { url in
                                if let selectedURL = url {
                                    let data = image.tiffRepresentation
                                    let bitmap = NSBitmapImageRep(data: data!)
                                    let jpeg = bitmap?.representation(using: .jpeg, properties: [:])
                                    try? jpeg?.write(to: selectedURL)
                                }
                            })
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
        ImageUniversalView(
            selectedImage: $selectedImage,
            selectedImagePath: $selectedImagePath,
            selectedImageName: $selectedImageName,
            selectedImageMetadata: $selectedImageMetadata,
            dropAction: { url in
                selectedImage = NSImage(contentsOf: url)
                selectedImagePath = url.path
                selectedImageName = url.lastPathComponent
                selectedImageMetadata = ImageMetadata(url: url)
            }
        )
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
