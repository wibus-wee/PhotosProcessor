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
                            let lsbWatermark = LSBWatermark()
                            lsbWatermark.encode(data: watermarkText, image: processImage.image!) { (image, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    if let image = image {
                                        processImage.image = image
                                        processImage.saveAs()
                                    }
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
                        if processImage.image != nil {
                            let lsbWatermark = LSBWatermark()
                            lsbWatermark.decode(from: processImage.image!) { (data, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    if let data = data {
                                        let string = String(data: data, encoding: .utf8)
                                        InternalKit.eazyAlert(
                                            title: "Decode Watermark",
                                            message: string ?? "No Watermark"
                                        )
                                    }
                                }
                            }
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
