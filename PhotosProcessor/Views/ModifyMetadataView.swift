//
//  ModifyMetadataView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

let supportMetadataKeys: [String: CFString] = [
    "DateTimeOriginal": kCGImagePropertyExifDateTimeOriginal,
    "DateTimeDigitized": kCGImagePropertyExifDateTimeDigitized,
    "DateTime": kCGImagePropertyTIFFDateTime,
    "ProfileName": kCGImagePropertyProfileName,
    "Software": kCGImagePropertyTIFFSoftware,
    "Make": kCGImagePropertyTIFFMake,
    "Model": kCGImagePropertyTIFFModel,
]

struct ModifyMetadataView: View {
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
    @State private var selectedImageMetadata: [String: Any]?

    @State private var newMetadataKey: String = ""
    @State private var newMetadataValue: String = ""
    @State private var copyFromKey: String = "DateTimeOriginal"


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
        .navigationTitle("Modify Metadata") 
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
                selectedImageMetadata = getImageMetadata(image: selectedImage!)
                print("[*] image metadata: \(selectedImageMetadata ?? [:])")
                
            }
        )
    }

    var rightColumn: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Copy from")
                    .font(.headline)
                    .foregroundColor(.gray)
                Picker("Copy from", selection: $copyFromKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 300, height: 30)
                .onChange(of: copyFromKey) { newValue in
                    if let metadata = selectedImageMetadata {
                        if let value = metadata[supportMetadataKeys[newValue]! as String] as? String {
                            newMetadataValue = value
                        }
                    }
                }
                .disabled(selectedImageMetadata == nil)
                .help("Copy from")
                Text("Value \(newMetadataValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 300, height: 30)
                    .help("Value")
                Divider()
            }
        }
    }
}
