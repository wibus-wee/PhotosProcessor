//
//  ImageUniversalView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct ImageUniversalView: View {
    @StateObject var processImage = ProcessImage.shared
    
    /// Deprecated. Use `ProcessImage.shared`` instead.
    // @Binding var selectedImage: NSImage?
    // @Binding var selectedImagePath: String?
    // @Binding var selectedImageName: String?
    // @Binding var selectedImageMetadata: ImageMetadata?

    var dropAction: (_ urls: URL) -> Void = { _ in }
    
    var body: some View {
        VStack {
            if let image = processImage.image {
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
                                        DispatchQueue.main.async {
                                            processImage.setup(url: url)
                                        }
                                        dropAction(url)
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
                                    DispatchQueue.main.async {
                                        processImage.setup(url: url)
                                    }
                                    dropAction(url)
                                }
                            }
                            return true
                        }
                        return false
                    }
                
            }
            Divider()
            VStack() {
                Text("Name: \(processImage.name ?? "No Image Selected")")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Size: \(Int(processImage.image?.size.width ?? 0)) x \(Int(processImage.image?.size.height ?? 0))")
                    .font(.caption)
                    .foregroundColor(.gray)
                if let metadata = processImage.imageMetadata {
                    if let profileName = metadata.getMetadata(key: kCGImagePropertyExifColorSpace) as? String {
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
}
