//
//  ImageGPSLocationView.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/29.
//

import SwiftUI
import MapKit

struct ImageGPSLocationView: View {
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var regionSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)

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
        HStack {
            if let imageMetadata = selectedImageMetadata {
                MapView(imageMetadata: imageMetadata, userTrackingMode: $userTrackingMode, regionSpan: $regionSpan)
                    .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
                    .cornerRadius(10)
                    .padding()
            } else {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))), showsUserLocation: true, userTrackingMode: .constant(.follow))
                    .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct ImageLocation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    let imageMetadata: ImageMetadata
    @Binding var userTrackingMode: MapUserTrackingMode
    @Binding var regionSpan: MKCoordinateSpan

    @State var annotations: [ImageLocation] = []

    init(imageMetadata: ImageMetadata, userTrackingMode: Binding<MapUserTrackingMode>, regionSpan: Binding<MKCoordinateSpan>) {
        self.imageMetadata = imageMetadata
        self._userTrackingMode = userTrackingMode
        self._regionSpan = regionSpan
        print("----------[New Map]----------")
    }

    var body: some View {
        Map(
            coordinateRegion: .constant(region(for: imageMetadata)),
            showsUserLocation: true,
            userTrackingMode: .constant(.follow),
            annotationItems: annotations, annotationContent: { annotation in
                MapMarker(coordinate: annotation.coordinate, tint: .red)
            }
        )
        .onAppear {
            annotations = []
            if let latitude = imageMetadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLatitude, area: "GPS")) as? NSNumber,
            let longitude = imageMetadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLongitude, area: "GPS")) as? NSNumber {
                print("[I] annotations Latitude: \(latitude)")
                print("[I] annotations Longitude: \(longitude)")
                let location = ImageLocation(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue))
                print("[I] annotations Location: \(location)")
                self.annotations.append(location)
            } else {
                print("[E] annotations Latitude or Longitude is nil")
            }
            print("[I] Annotations: \(self.annotations)")
        }
    }
    
    private func region(for metadata: ImageMetadata) -> MKCoordinateRegion {
        guard let latitude = metadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLatitude, area: "GPS")) as? NSNumber,
              let longitude = metadata.getMetadata(key: MetadataKey(key: kCGImagePropertyGPSLongitude, area: "GPS")) as? NSNumber else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: regionSpan
                // latitudinalMeters: 100,
                // longitudinalMeters: 100
            )
        }
        
        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue),
            span: regionSpan
            // latitudinalMeters: 100,
            // longitudinalMeters: 100
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
