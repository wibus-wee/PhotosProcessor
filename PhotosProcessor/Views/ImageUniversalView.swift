//
//  ImageUniversalView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/24.
//

import SwiftUI

struct ImageUniversalView: View {
    @Binding var selectedImage: NSImage?
    @Binding var selectedImagePath: String?
    @Binding var selectedImageName: String?
    @Binding var selectedImageMetadata: [String: Any]?

    var dropAction: (_ url: URL) -> Void
    
    var body: some View {
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
                Text("Name: \(selectedImageName ?? "No Image Selected")")
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
}
