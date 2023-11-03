//
//  ModifyMetadataView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/10.
//

import SwiftUI

let supportMetadataKeys: [String: MetadataKey] = [
    // 创建时间
    "DateTimeOriginal": MetadataKey(key: kCGImagePropertyExifDateTimeOriginal, area: "Exif"),
    // 修改时间
    "DateTimeDigitized": MetadataKey(key: kCGImagePropertyExifDateTimeDigitized, area: "Exif"),
    // 文件创建时间
    "CreateDate": MetadataKey(key: kCGImagePropertyTIFFDateTime, area: "TIFF"),
    // 色彩 profile
    "ProfileName": MetadataKey(key: kCGImagePropertyProfileName, area: ""),
    // 设备制造商
    "Make": MetadataKey(key: kCGImagePropertyTIFFMake, area: "TIFF"),
    // 设备型号
    "Model": MetadataKey(key: kCGImagePropertyTIFFModel, area: "TIFF"),
    // 颜色模式
    "ColorModel": MetadataKey(key: kCGImagePropertyColorModel, area: ""),
    // 镜头型号
    "LensModel": MetadataKey(key: kCGImagePropertyExifAuxLensModel, area: "ExifAux"),
    // 描述
    "ImageDescription": MetadataKey(key: kCGImagePropertyTIFFImageDescription, area: "TIFF"),
    // 注释
    "UserComment": MetadataKey(key: kCGImagePropertyExifUserComment, area: "Exif"),
    // 软件
    "Software": MetadataKey(key: kCGImagePropertyTIFFSoftware, area: "TIFF"),
]

let supportArea: [String] = [
    "Exif",
    "ExifAux",
    "TIFF",
    "GPS",
    "IPTC",
]


struct ModifyMetadataView: View {
    @StateObject var processImage = ProcessImage.shared
    
    enum ModifyType: String {
        case copy = "Copy"
        case edit = "Edit"
        case remove = "Remove"
        case add = "Add"
    }
    
    @State private var isPresented: Bool = false
    @State private var modifyType: ModifyType = .copy
    
    @State private var copyFromKey: String = "DateTimeOriginal"
    @State private var processMetadataKeyInputType: String = "Picker"
    @State private var processMetadataKey: String = "DateTimeOriginal"
    @State private var oldProcessMetadataValue: String = ""
    @State private var newProcessMetadataValue: String = ""
    
    @State private var imageViewBlurRadius: Double = 0
    
    func customKeyRegex() {
        // Feature: Regex Support.
        // 如果是正则表达式，那么就用正则表达式去匹配
        if (self.processMetadataKey.starts(with: "/") && self.processMetadataKey.ends(with: "/")) {
            print("[*] \(self.processMetadataKey) is a regex.")
            let regex = try! NSRegularExpression(pattern: self.processMetadataKey)
            let metadata = processImage.imageMetadata?.metadata
            for (key, value) in metadata! {
                let keyString = "\(key)"
                let valueString = "\(value)"
                let range = NSRange(location: 0, length: keyString.utf16.count)
                if regex.firstMatch(in: keyString, options: [], range: range) != nil {
                    print("[*] \(keyString) matched.")
                    oldProcessMetadataValue = "\(valueString)"
                    if (modifyType == .edit) {
                        newProcessMetadataValue = "\(valueString)"
                    }
                    return
                }
            }
        }
    }
    
    func customKcgKey() {
        // Feature: 如果以 kCGImageProperty 开头，表明是 Core Graphics 的 key
        if (self.processMetadataKey.starts(with: "kCGImageProperty")) {
            print("[*] \(self.processMetadataKey) is a Core Graphics key. Try to analyze it.")
            // kCGImageProperty 的构成为：kCGImageProperty + Area(Optional) + Key
            // 例如：kCGImagePropertyExifDateTimeOriginal, kCGImagePropertyColorModel
            // Start.
            let spliter = self.processMetadataKey.split(separator: "kCGImageProperty")
            print("[*] spliter: \(spliter)")
            // 检查一下后面还有没有东西
            if spliter.count < 1 {
                print("[*] There is no key after kCGImageProperty.")
                return
            }
            let preKey = spliter[0]
            print("[*] preKey: \(preKey)")
            // 尝试分割 Area, 把 supportArea 中的每个元素都尝试一遍
            var areaKey: Substring? = nil
            for area in supportArea {
                if preKey.starts(with: area) {
                    print("[*] area matched: \(area)")
                    areaKey = Substring(area)
                    break
                }
            }
            let keyKey: Substring
            if let areaKey = areaKey {
                let spliter = preKey.split(separator: areaKey);
                print("[*] spliter: \(spliter)")
                keyKey = preKey.split(separator: areaKey)[0]
            } else {
                keyKey = preKey
            }
            print("[*] keyKey: \(keyKey)")
            
            // End.
            let value = processImage.imageMetadata?.getMetadata(key: MetadataKey(key: keyKey as CFString, area: String(areaKey!) as String))
            print("[*] value: \(String(describing: value))")
            oldProcessMetadataValue = "\(value ?? "")"
            if (modifyType == .edit) {
                newProcessMetadataValue = "\(value ?? "")"
            }
            return
        }
    }
    
    func updateProcessMetadataValue() {
        if (modifyType == .copy ){
            let copyFromKey = supportMetadataKeys[self.copyFromKey]
            if (copyFromKey == nil) {
                newProcessMetadataValue = ""
                return
            }
            let newMetadataValue = processImage.imageMetadata?.getMetadata(key: copyFromKey!)
            newProcessMetadataValue = "\(newMetadataValue ?? "")"
        }
        if modifyType == .remove {
            newProcessMetadataValue = "nil"
        }
        let key = supportMetadataKeys[self.processMetadataKey]
        if (key == nil) { // 如果不在默认的支持列表中，表明是自定义的 key
            print("[*] \(self.processMetadataKey) is not in supportMetadataKeys. And try to use it as custom key.")

            customKeyRegex()
            customKcgKey()
            
            oldProcessMetadataValue = ""
            if (modifyType == .edit) {
                newProcessMetadataValue = ""
            }
            return
        }
        // let oldMetadataValue = getImageMetadata(url: selectedImageURL!, key: key!)
        let oldMetadataValue = processImage.imageMetadata?.getMetadata(key: key!)
        if (modifyType == .edit) {
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
        .sheet(isPresented: $isPresented) {
            let title: Binding<String> = .constant("Image Metadata")
            let data: Binding<Any?> = .constant(processImage.imageMetadata?.metadata)
            AnyDataView(title: title, data: data)
        }
        .navigationTitle("Modify Metadata")
        .toolbar {
            Group {
                ToolbarItem {
                    Button {
                        isPresented = true
                    } label: {
                        Label("Image Metadata", systemImage: "info.circle")
                    }
                    .help("Image Metadata")
                    .disabled(!processImage.inited)
                }
                ToolbarItem {
                    Button {
                        if (!processImage.inited) {
                            return
                        }
                        let _ = processImage.imageMetadata!.syncImageDate(path: processImage.imageMetadata!.url!.path)
                        processImage.refresh()
                    } label: {
                        Label("Sync DateTimeOriginal to CreateDate", systemImage: "arrow.clockwise")
                    }
                    .help("Sync DateTimeOriginal to CreateDate")
                    .disabled(!processImage.inited)
                }
                // Start Modify
                ToolbarItem {
                    Button {
                        if (!processImage.inited) {
                            return
                        }
                        // set blur radius to 10 gradually
                        withAnimation(.easeInOut(duration: 0.5)) {
                            imageViewBlurRadius = 10
                        }
                        var res = false
                        let metadata = processImage.imageMetadata!
                        if modifyType == .copy {
                            let copyFromKey = supportMetadataKeys[self.copyFromKey]
                            let processKey = supportMetadataKeys[self.processMetadataKey]
                            if (copyFromKey == nil || processKey == nil) {
                                return
                            }
                            res = metadata.copyMetadata(from: copyFromKey!, to: processKey!)
                        }
                        if modifyType == .edit {
                            let processKey = supportMetadataKeys[self.processMetadataKey]
                            if (processKey == nil) {
                                return
                            }
                            res = metadata.editMetadata(key: processKey!, value: newProcessMetadataValue)
                        }
                        if modifyType == .remove {
                            let processKey = supportMetadataKeys[self.processMetadataKey]
                            if (processKey == nil) {
                                return
                            }
                            res = metadata.removeMetadata(key: processKey!)
                        }
                        if modifyType == .add {
                            let processKey = supportMetadataKeys[self.processMetadataKey]
                            if (processKey == nil) {
                                return
                            }
                            res = metadata.addMetadata(key: processKey!, value: newProcessMetadataValue)
                        }
                        if (!res) {
                            print("[E] Bug occurred when edit metadata")
                            InternalKit.eazyAlert(title: "Error", message: "Bug occurred when edit metadata")
                        }
                        processImage.refresh()
                        // set blur radius to 0 gradually. now + 1s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                imageViewBlurRadius = 0
                            }
                        }
                    } label: {
                        Label("Modify", systemImage: "play")
                    }
                    .help("Modify")
                    .disabled(!processImage.inited)
                }
            }
        }
    }
    
    var leftColumn: some View {
        ImageUniversalView(
            dropAction: { url in
                updateProcessMetadataValue()
            }
        )
        .blur(radius: CGFloat(imageViewBlurRadius))
    }
    
    var rightTop: some View {
        VStack(alignment: .leading) {
            Picker("Modify Type", selection: $modifyType) {
                Text("Copy").tag(ModifyType.copy)
                Text("Edit").tag(ModifyType.edit)
                Text("Add").tag(ModifyType.add)
                Text("Remove").tag(ModifyType.remove)
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
                .disabled(!processImage.inited)
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
                .disabled(!processImage.inited)
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
                        .disabled(!processImage.inited)
                        .help("Process metadata key")
                    // .onChange(of: processMetadataKey) { _ in
                    //     updateProcessMetadataValue()
                    // }
                        .onSubmit(of: .text) {
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
                    .disabled(!processImage.inited)
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
            .disabled(!processImage.inited)
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
                    .disabled(!processImage.inited)
                    .help("New metadata key")
                // .onChange(of: processMetadataKey) { _ in
                //     updateProcessMetadataValue()
                // }
                    .onSubmit(of: .text) {
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
                .disabled(!processImage.inited)
                .help("Metadata key")
                .onChange(of: processMetadataKey) { _ in
                    updateProcessMetadataValue()
                }
                // .onSubmit(of: .text) {
                //     updateProcessMetadataValue()
                // }
            }
            
            // TextField-like TextEditor
            TextEditor(text: $newProcessMetadataValue)
                .font(.system(size: 12, design: .monospaced))
                .background(Color(NSColor.textBackgroundColor))
                .frame(height: 100)
                .disabled(!processImage.inited)
                .help("Metadata value")
            // .onChange(of: newProcessMetadataValue) { _ in
            //     updateProcessMetadataValue()
            // }
        }
    }
    
    var removeView: some View {
        VStack(alignment: .leading) {
            Picker("Metadata key", selection: $processMetadataKeyInputType) {
                Text("Picker").tag("Picker")
                Text("Input").tag("Input")
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(!processImage.inited)
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
                    .disabled(!processImage.inited)
                    .help("Metadata key")
                // .onChange(of: processMetadataKey) { _ in
                //     updateProcessMetadataValue()
                // }
                    .onSubmit(of: .text) {
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
                .disabled(!processImage.inited)
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
            .disabled(!processImage.inited)
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
                    .disabled(!processImage.inited)
                    .help("Metadata key")
            } else {
                Picker("Metadata key", selection: $processMetadataKey) {
                    ForEach(supportMetadataKeys.keys.sorted(), id: \.self) { key in
                        Text(key)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                // .frame(width: 300, height: 30)
                .disabled(!processImage.inited)
                .help("Metadata key")
            }
            
            TextField("Metadata value", text: $newProcessMetadataValue)
            // .frame(width: 300, height: 30)
                .disabled(!processImage.inited)
                .help("Metadata value")
        }
    }
    
    var rightColumn: some View {
        VStack(alignment: .leading) {
            
            rightTop
            Divider()
            if modifyType == .copy {
                copyView
            } else if modifyType == .edit {
                editView
            } else if modifyType == .remove {
                removeView
            } else if modifyType == .add {
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
                    Text(modifyType.rawValue)
                        .font(.caption)
                }
                if modifyType == .copy {
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
                    if modifyType == .remove {
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
