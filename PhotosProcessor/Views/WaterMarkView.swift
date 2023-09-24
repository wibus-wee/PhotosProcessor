//
//  WaterMarkView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct WaterMarkView: View {
    @State private var selectedImage: NSImage?
    @State private var selectedImagePath: String?
    @State private var selectedImageName: String = ""
    @State private var selectedImageMetadata: [String: Any]?
    
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
                                selectedImageMetadata = getImageMetadata(image: selectedImage!)
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
        VStack {
            if let image = selectedImage {
                VStack {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .cornerRadius(8)
                        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                    if let url = object {
                                        selectedImage = NSImage(contentsOf: url)
                                        selectedImagePath = url.path
                                        selectedImageName = url.lastPathComponent
                                        selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                    }
                                }
                                return true
                            }
                            return false
                        }
                }
                
            } else {
                Text("Choose Image")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(width: 300, height: 300)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(8)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    selectedImage = NSImage(contentsOf: url)
                                    selectedImagePath = url.path
                                    selectedImageName = url.lastPathComponent
                                    selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                }
                            }
                            return true
                        }
                        return false
                    }
                
            }
            Divider()
            VStack() {
                Text("\(selectedImageName == "" ? "No Image Selected" : selectedImageName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Size: \(Int(selectedImage?.size.width ?? 0)) x \(Int(selectedImage?.size.height ?? 0))")
                    .font(.caption)
                    .foregroundColor(.gray)
                if let metadata = selectedImageMetadata {
                    if let profileName = getColorProfileFromMetadata(metadata: metadata) {
                        Text("Color Profile: \(profileName)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Color Profile: Unknown")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
        }
        .padding()
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
