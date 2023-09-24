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
    "Make": kMDItemAcquisitionMake,
    "Model": kMDItemAcquisitionModel,
    "Creator": kMDItemCreator,
]

struct ModifyMetadataView: View {
    @State private var modifyType: String = "Copy" // Copy, Edit, Remove, Add
    
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
    
    @State private var copyFromKey: String = "DateTimeOriginal"
    @State private var processMetadataKeyInputType: String = "Picker"
    @State private var processMetadataKey: String = "DateTimeOriginal"
    @State private var oldProcessMetadataValue: String = ""
    @State private var newProcessMetadataValue: String = ""
    
    func updateProcessMetadataValue() {
        if (modifyType == "Copy" ){
            let copyFromKey = supportMetadataKeys[self.copyFromKey]!
            let newMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: copyFromKey)
            newProcessMetadataValue = "\(newMetadataValue ?? "")"
        }
        if modifyType == "Remove" {
            newProcessMetadataValue = "nil"
        }
        let key = supportMetadataKeys[self.processMetadataKey]!
        let oldMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: key)
        if (modifyType == "Edit") {
            newProcessMetadataValue = "\(oldMetadataValue ?? "")"
        }
        oldProcessMetadataValue = "\(oldMetadataValue ?? "")"
        
    }
    
    
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
                                updateProcessMetadataValue()
                                // let newProcessMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: supportMetadataKeys[copyFromKey]!)
                                // self.newProcessMetadataValue = "\(newProcessMetadataValue ?? "")"
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
                updateProcessMetadataValue()
                // let newProcessMetadataValue = getImageMetadataFromMDItem(url: selectedImageURL!, key: supportMetadataKeys[copyFromKey]!)
                // self.newProcessMetadataValue = "\(newProcessMetadataValue ?? "")"
            }
        )
    }
    
    var rightTop: some View {
        VStack(alignment: .leading) {
            Picker("Modify Type", selection: $modifyType) {
                Text("Copy").tag("Copy")
                Text("Edit").tag("Edit")
                Text("Add").tag("Add")
                Text("Remove").tag("Remove")
            }
            .pickerStyle(SegmentedPickerStyle())
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
                .onChange(of: copyFromKey) { _ in
                    updateProcessMetadataValue()
                }
                .disabled(selectedImageMetadata == nil)
                .help("Copy from")
                Text("Select a metadata key to copy from.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Picker("Copy to", selection: $processMetadataKeyInputType) {
                    Text("Picker").tag("Picker")
                    Text("Input").tag("Input")
                }
                .pickerStyle(SegmentedPickerStyle())
                // .frame(width: 300, height: 30)
                .onChange(of: processMetadataKeyInputType) { newValue in
                    if newValue == "Input" {
                        processMetadataKey = ""
                    } else {
                        processMetadataKey = supportMetadataKeys.keys.sorted()[0]
                    }
                }
                .help("Copy to")
                Text("Select a metadata key to copy to.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if processMetadataKeyInputType == "Input" {
                    TextField("Process metadata key", text: $processMetadataKey)
                    // .frame(width: 300, height: 30)
                        .disabled(selectedImageMetadata == nil)
                        .help("Process metadata key")
                        .onChange(of: processMetadataKey) { _ in
                            updateProcessMetadataValue()
                        }
                } else {
                    Picker("Process metadata key", selection: $processMetadataKey) {
                        ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                            Text(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("Process metadata key")
                    .onChange(of: processMetadataKey) { _ in
                        updateProcessMetadataValue()
                    }
                }
                
            }
        }
    }
    
    var editView: some View {
        VStack(alignment: .leading) {
            Picker("Metadata key", selection: $processMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            // .frame(width: 300, height: 30)
            .onChange(of: processMetadataKeyInputType) { newValue in
                if newValue == "Input" {
                    processMetadataKey = ""
                } else {
                    processMetadataKey = supportMetadataKeys.keys.sorted()[0]
                }
                updateProcessMetadataValue()
            }
            .help("Metadata key")
            Text("Select a metadata key to modify")
                .font(.caption)
                .foregroundColor(.secondary)
            if processMetadataKeyInputType == "Input" {
                TextField("New metadata key", text: $processMetadataKey)
                // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("New metadata key")
                    .onChange(of: processMetadataKey) { _ in
                        updateProcessMetadataValue()
                    }
            } else {
                Picker("Metadata key", selection: $processMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("Metadata key")
                .onChange(of: processMetadataKey) { _ in
                    updateProcessMetadataValue()
                }
            }
            
            TextField("Metadata value", text: $newProcessMetadataValue)
            // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("Metadata value")
        }
    }
    
    var removeView: some View {
        VStack(alignment: .leading) {
            Picker("Metadata key", selection: $processMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            // .frame(width: 300, height: 30)
            .onChange(of: processMetadataKeyInputType) { newValue in
                if newValue == "Input" {
                    processMetadataKey = ""
                } else {
                    processMetadataKey = supportMetadataKeys.keys.sorted()[0]
                }
                updateProcessMetadataValue()
            }
            .help("Metadata key")
            Text("Select a metadata key to remove")
                .font(.caption)
                .foregroundColor(.secondary)
            if processMetadataKeyInputType == "Input" {
                TextField("Metadata key", text: $processMetadataKey)
                // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("Metadata key")
                    .onChange(of: processMetadataKey) { _ in
                        updateProcessMetadataValue()
                    }
            } else {
                Picker("Metadata key", selection: $processMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("Metadata key")
                .onChange(of: processMetadataKey) { _ in
                    updateProcessMetadataValue()
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    var addView: some View {
        VStack(alignment: .leading) {
            Picker("Metadata key", selection: $processMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            // .frame(width: 300, height: 30)
            .onChange(of: processMetadataKeyInputType) { newValue in
                if newValue == "Input" {
                    processMetadataKey = ""
                } else {
                    processMetadataKey = supportMetadataKeys.keys.sorted()[0]
                }
            }
            .help("Metadata key")
            Text("Select a metadata key to add")
                .font(.caption)
                .foregroundColor(.secondary)
            if processMetadataKeyInputType == "Input" {
                TextField("Metadata key", text: $processMetadataKey)
                // .frame(width: 300, height: 30)
                    .disabled(selectedImageMetadata == nil)
                    .help("Metadata key")
            } else {
                Picker("Metadata key", selection: $processMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("Metadata key")
            }
            
            TextField("Metadata value", text: $newProcessMetadataValue)
            // .frame(width: 300, height: 30)
                .disabled(selectedImageMetadata == nil)
                .help("Metadata value")
        }
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
            } else if modifyType == "Add" {
                addView
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
                if modifyType == "Copy" {
                    HStack {
                        Text("Copy from")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(copyFromKey)
                            .font(.caption)
                    }
                }
                HStack {
                    Text("Modified metadata key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(processMetadataKey)
                        .font(.caption)
                }
                HStack {
                    Text("Old metadata value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(oldProcessMetadataValue)
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
                        Text(newProcessMetadataValue)
                            .font(.caption)
                    }
                }
                HStack {
                    Text("Process Flow")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(oldProcessMetadataValue) -> \(newProcessMetadataValue)")
                        .font(.caption)
                }
                
            }
        }
        .padding()
    }
}
