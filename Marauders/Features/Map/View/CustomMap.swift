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

        // 🔥 set initial region ครั้งเดียว
        map.setRegion(region, animated: false)

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        map.addGestureRecognizer(tap)

        // ✅ รอ map render จริง
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onMapReady()
        }

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ❌ ไม่ setRegion ทุกครั้ง
        // ปล่อย map control ตัวเอง
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMap
        private var currentAnnotation: MKPointAnnotation?
        private var currentOverlay: MKCircle?

        init(_ parent: CustomMap) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }

            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)

            parent.onTap(coord)

            // 🔥 update เฉพาะของเก่า (ไม่ clear ทั้ง map)
            if let annotation = currentAnnotation {
                mapView.removeAnnotation(annotation)
            }

            if let overlay = currentOverlay {
                mapView.removeOverlay(overlay)
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = coord

            let circle = MKCircle(center: coord, radius: 1000)

            mapView.addAnnotation(annotation)
            mapView.addOverlay(circle)

            currentAnnotation = annotation
            currentOverlay = circle
        }

        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
            if fullyRendered {
                parent.onMapReady()
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circle = overlay as? MKCircle else {
                return MKOverlayRenderer()
            }

            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = .systemBlue
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
            renderer.lineWidth = 2
            return renderer
        }
    }
}

