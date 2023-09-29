//
//  ImageGPSLocationView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/29.
//

import SwiftUI
import MapKit

struct ImageGPSLocationView: View {
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
    @State private var selectedImageMetadata: ImageMetadata?

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
        .navigationTitle("Image GPS Location")
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
                selectedImageMetadata = ImageMetadata(url: url)
            }
        )
    }


    var rightColumn: some View {
      Group {
        if let imageMetadata = selectedImageMetadata {
          MapView(imageMetadata: imageMetadata)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
            .cornerRadius(10)
            .padding()
        } else {
          Text("No image selected")
        }
      }
    }
}

struct MapView: View {
    let imageMetadata: ImageMetadata

    var body: some View {
        Map(coordinateRegion: .constant(region(for: imageMetadata)), showsUserLocation: true)
    }

    private func region(for metadata: ImageMetadata) -> MKCoordinateRegion {
        guard let latitude = metadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLatitude, area: "GPS")) as? NSNumber,
              let longitude = metadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLongitude, area: "GPS")) as? NSNumber else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                // span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                latitudinalMeters: 100,
                longitudinalMeters: 100
            )
        }

        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue),
            // span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            latitudinalMeters: 100,
            longitudinalMeters: 100
        )

        let latitudeRefMetadataKey = MetadataKey(key: kCGImagePropertyGPSLatitudeRef, area: "GPS")
        let longitudeRefMetadataKey = MetadataKey(key: kCGImagePropertyGPSLongitudeRef, area: "GPS")

        if let latitudeRef = metadata.getMetadata(key: latitudeRefMetadataKey) as? String,
           let longitudeRef = metadata.getMetadata(key: longitudeRefMetadataKey) as? String {
            if latitudeRef == "S" {
                region.center.latitude *= -1.0
            }

            if longitudeRef == "W" {
                region.center.longitude *= -1.0
            }
        }

        print("[I] Region: \(region)")
        
        return region
    }
}
