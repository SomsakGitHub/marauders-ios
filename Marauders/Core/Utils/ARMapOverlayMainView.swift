//
//  ARMapOverlayMainView.swift
//  Marauders
//
//  Created by User on 25/11/2025.
//

import SwiftUI
import MapKit
import RealityKit
import ARKit
import CoreLocation
import Combine

// MARK: - Identifiable Wrapper สำหรับ MKPolygon
struct MapOverlay: Identifiable {
    let id = UUID()
    let polygon: MKPolygon
}

// Extension ช่วยดึง coordinates จาก MKPolygon
extension MKPolygon {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
}

// MARK: - MapView with Polygon Overlays
struct MapWithPolygons: UIViewRepresentable {
    @Binding var overlays: [MapOverlay]
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        for overlay in overlays {
            uiView.addOverlay(overlay.polygon)
        }
        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithPolygons
        init(_ parent: MapWithPolygons) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = .blue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

// MARK: - ARMapOverlayMainView
struct ARMapOverlayMainView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MapOverlay] = []
    @State private var isLoading = false
    @State private var fadeIn = false

    // Default region
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack {
            // MARK: Map with Polygons
            MapWithPolygons(overlays: $overlays, region: $region)
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeIn(duration: 0.6), value: fadeIn)

            // MARK: AR Overlay
            ARViewContainer(overlays: $overlays)
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeIn(duration: 0.6), value: fadeIn)

            // MARK: ProgressView
            if isLoading {
                ProgressView("Analyzing Map...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .transition(.opacity)
            }

            // MARK: AI Button
            VStack {
                Spacer()
                Button(action: generateOverlay) {
                    Text("Generate AI Overlay")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            fadeIn = true
            locationManager.requestPermission()
            if let location = locationManager.userLocation {
                region.center = location.coordinate
            }
        }
    }

    // MARK: - Generate Overlay
    func generateOverlay() {
        Task {
            withAnimation {
                isLoading = true
                fadeIn = false
            }
            overlays = await fetchAIOverlay()
            withAnimation {
                isLoading = false
                fadeIn = true
            }
        }
    }

    // MARK: - AI Overlay (mock)
    func fetchAIOverlay() async -> [MapOverlay] {
        // จำลองการประมวลผล AI
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let coords = [
            CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
            CLLocationCoordinate2D(latitude: 13.7570, longitude: 100.5020),
            CLLocationCoordinate2D(latitude: 13.7560, longitude: 100.5030)
        ]
        let polygon = MKPolygon(coordinates: coords, count: coords.count)
        return [MapOverlay(polygon: polygon)]
    }
}

// MARK: - ARViewContainer
struct ARViewContainer: UIViewRepresentable {
    @Binding var overlays: [MapOverlay]

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.scene.anchors.removeAll()
        for overlay in overlays {
            let anchor = AnchorEntity(world: SIMD3<Float>(0,0,0))
            for coord in overlay.polygon.coordinates {
                let entity = ModelEntity(mesh: MeshResource.generateBox(size: 0.01))
                entity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                // แปลง Lat/Lon เป็น Relative Position
                entity.position = SIMD3<Float>(Float(coord.latitude - 13.7563),
                                               0,
                                               Float(coord.longitude - 100.5018))
                anchor.addChild(entity)
            }
            uiView.scene.addAnchor(anchor)
        }
    }
}

// MARK: - Preview
struct ARMapOverlayMainView_Previews: PreviewProvider {
    static var previews: some View {
        ARMapOverlayMainView()
    }
}
