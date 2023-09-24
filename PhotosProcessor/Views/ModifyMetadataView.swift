//
//  ModifyMetadataView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

let supportMetadataKeys: [String: CFString] = [
    "DateTimeOriginal": kMDItemContentCreationDate,
    "DateTimeDigitized": kMDItemContentModificationDate,
    "FSCreationDate": kMDItemFSCreationDate,
    "FSContentChangeDate": kMDItemFSContentChangeDate,
    "ProfileName": kMDItemProfileName,
    "Timestamp": kMDItemTimestamp,
]

struct ModifyMetadataView: View {
    @State private var modifyType: String = "Copy" // Copy, Edit, Remove
    
    @State private var selectedImage: NSImage? = nil {
        didSet {
            if selectedImage == nil {
                selectedImageURL = nil
                selectedImagePath = ""
                selectedImageName = ""
                selectedImageMetadata = nil
            }
        }
    }
    @State private var selectedImageURL: URL?
    @State private var selectedImagePath: String?
    @State private var selectedImageName: String?
    @State private var selectedImageMetadata: [String: Any]?
    
    @State private var newMetadataKeyInputType: String = "Picker" // Input, Picker
    @State private var newMetadataKey: String = "DateTimeOriginal"
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
                                selectedImageURL = selectedURL
                                selectedImagePath = selectedURL.path
                                selectedImageName = selectedURL.lastPathComponent
                                selectedImageMetadata = getImageMetadata(image: selectedImage!)
                                let newMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: supportMetadataKeys[copyFromKey]!)
                                self.newMetadataValue = "\(newMetadataValue ?? "")"
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
                selectedImageURL = url
                selectedImagePath = url.path
                selectedImageName = url.lastPathComponent
                selectedImageMetadata = getImageMetadata(image: selectedImage!)
                let newMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: supportMetadataKeys[copyFromKey]!)
                self.newMetadataValue = "\(newMetadataValue ?? "")"
            }
        )
    }
    
    var rightTop: some View {
        VStack(alignment: .leading) {
            Picker("Modify Type", selection: $modifyType) {
                Text("Copy").tag("Copy")
                Text("Edit").tag("Edit")
                Text("Remove").tag("Remove")
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300)
            .help("Modify Type")
        }
    }
    
    var copyView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Picker("Copy from", selection: $copyFromKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: copyFromKey) { newValue in
                    if let key = supportMetadataKeys[newValue] {
                        let metadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: key)
                        newMetadataValue = "\(metadataValue ?? "")"
                    } else {
                        InternalKit.eazyAlert(title: "Error", message: "Unsupported metadata key: \(newValue)")
                    }
                }
                .disabled(selectedImageMetadata == nil)
                .help("Copy from")
                Text("Select a metadata key to copy from.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Picker("New metadata key", selection: $newMetadataKeyInputType) {
                    Text("Picker").tag("Picker")
                    Text("Input").tag("Input")
                }
                .pickerStyle(SegmentedPickerStyle())
                // .frame(width: 300, height: 30)
                .onChange(of: newMetadataKeyInputType) { newValue in
                    if newValue == "Input" {
                        newMetadataKey = ""
                    } else {
                        newMetadataKey = supportMetadataKeys.keys.sorted()[0]
                    }
                }
                .help("New metadata key")
                Text("Select a metadata key to modify")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if newMetadataKeyInputType == "Input" {
                    TextField("New metadata key", text: $newMetadataKey)
                    // .frame(width: 300, height: 30)
                        .disabled(selectedImageMetadata == nil)
                        .help("New metadata key")
                } else {
                    Picker("New metadata key", selection: $newMetadataKey) {
                        ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                            Text(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("New metadata key")
                }
                
            }
        }
    }
    
    var editView: some View {
        VStack(alignment: .leading) {
            Picker("New metadata key", selection: $newMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            // .frame(width: 300, height: 30)
            .onChange(of: newMetadataKeyInputType) { newValue in
                if newValue == "Input" {
                    newMetadataKey = ""
                } else {
                    newMetadataKey = supportMetadataKeys.keys.sorted()[0]
                }
            }
            .help("New metadata key")
            Text("Select a metadata key to modify")
                .font(.caption)
                .foregroundColor(.secondary)
            if newMetadataKeyInputType == "Input" {
                TextField("New metadata key", text: $newMetadataKey)
                // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("New metadata key")
            } else {
                Picker("New metadata key", selection: $newMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("New metadata key")
            }
            
            TextField("New metadata value", text: $newMetadataValue)
            // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("New metadata value")
        }
    }

    var removeView: some View {
        VStack(alignment: .leading) {
            Picker("New metadata key", selection: $newMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            // .frame(width: 300, height: 30)
            .onChange(of: newMetadataKeyInputType) { newValue in
                if newValue == "Input" {
                    newMetadataKey = ""
                } else {
                    newMetadataKey = supportMetadataKeys.keys.sorted()[0]
                }
            }
            .help("New metadata key")
            Text("Select a metadata key to modify")
                .font(.caption)
                .foregroundColor(.secondary)
            if newMetadataKeyInputType == "Input" {
                TextField("New metadata key", text: $newMetadataKey)
                // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("New metadata key")
            } else {
                Picker("New metadata key", selection: $newMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("New metadata key")
            }
        }
        .padding(.bottom, 20)
    }
    
    var rightColumn: some View {
        VStack(alignment: .leading) {
            
            rightTop
            Divider()
            if modifyType == "Copy" {
                copyView
            } else if modifyType == "Edit" {
                editView
            } else if modifyType == "Remove" {
                removeView
            }
            Divider()
            VStack(alignment: .leading) {
                HStack {
                    Text("Configuration Preview")
                    .font(.headline)
                    .padding(.bottom, 5)
                }
                HStack {
                    Text("Modify Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(modifyType)
                        .font(.caption)
                }
                HStack {
                    Text("New metadata key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(newMetadataKey)
                        .font(.caption)
                }
                HStack {
                    Text("New metadata value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if modifyType == "Remove" {
                        Text("nil")
                            .font(.caption)
                    } else {
                        Text(newMetadataValue)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}
