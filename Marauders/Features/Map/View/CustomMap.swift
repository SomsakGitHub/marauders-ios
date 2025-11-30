import SwiftUI
import MapKit

struct CustomMap: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onTap: (CLLocationCoordinate2D) -> Void
    var onMapReady: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        map.addGestureRecognizer(tap)

        DispatchQueue.main.async { onMapReady() }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMap

        init(_ parent: CustomMap) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }

            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)

            parent.onTap(coord)

            // clear + redraw
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)

            mapView.addAnnotation(MKPointAnnotation(coordinate: coord))
            mapView.addOverlay(MKCircle(center: coord, radius: 1000))
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = .systemBlue
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

