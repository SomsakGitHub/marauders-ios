import SwiftUI
import MapKit

// View หลักที่แสดงแผนที่
struct MapView: View {
    var body: some View {
        CustomMap() // เรียกใช้ Custom UIViewRepresentable map
    }
}

#Preview {
    MapView()
}

// MARK: - CustomMap: ใช้ UIViewRepresentable เพื่อเชื่อม MKMapView เข้ากับ SwiftUI
struct CustomMap: UIViewRepresentable {
    // พิกัดที่เลือก (optional) สำหรับเก็บจุดที่ user แตะ
    var coordinate: CLLocationCoordinate2D?
    
    // ตัวจัดการตำแหน่งผู้ใช้
    var locationManager = LocationManager()

    // MARK: - Coordinator สำหรับจัดการ delegate & gesture
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - สร้าง UIView (MKMapView)
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator       // ตั้ง delegate ให้ Coordinator
        mapView.showsUserLocation = true             // แสดงจุดตำแหน่งผู้ใช้บนแผนที่
        
        // ขอให้ LocationManager ขอข้อมูลตำแหน่งปัจจุบัน
        locationManager.requestLocation()
        
        // ถ้ามีตำแหน่งผู้ใช้แล้ว → ขยับกล้องไปยังจุดนั้น
        if let location = locationManager.manager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
        }
        
        // เพิ่ม gesture recognizer สำหรับแตะบนแผนที่
        let gesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(gesture)
        
        return mapView
    }

    // MARK: - อัปเดต UIView (กรณี SwiftUI state เปลี่ยน)
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ปัจจุบันยังไม่มีการอัปเดต dynamic ใด ๆ
    }

    // MARK: - Coordinator Class
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMap
        
        // ใช้ Environment สำหรับ CoreData หรือ ModelContext (ถ้ามี)
        @Environment(\.modelContext) private var context

        init(_ parent: CustomMap) {
            self.parent = parent
        }

        // MARK: - Gesture handler เมื่อผู้ใช้แตะบนแผนที่
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view) // แปลงตำแหน่งแตะให้เป็น CGPoint
            
            if let mapView = gesture.view as? MKMapView {
                // แปลงตำแหน่ง CGPoint → พิกัด CLLocationCoordinate2D
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                
                print("coordinate.latitude => \(coordinate.latitude)")
                print("coordinate.longitude => \(coordinate.longitude)")
                
                // เก็บพิกัดไว้ใน parent (CustomMap)
                parent.coordinate = coordinate
                
                // (optional) เก็บลง Shared Setting ถ้ามี
                // AppSettings.shared.latitude = coordinate.latitude
                // AppSettings.shared.longitude = coordinate.longitude

                // ลบ pin และ overlay เดิมก่อนวาดใหม่
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
                
                // ✅ วาง pin ใหม่ในจุดที่แตะ
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                
                // ✅ วาดวงกลมรัศมีรอบจุดแตะ (1 km)
                let circle = MKCircle(center: coordinate, radius: 1000)
                mapView.addOverlay(circle)
            }
        }
        
        // MARK: - สร้าง renderer สำหรับ overlay (เช่น วงกลม)
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3) // พื้นโปร่งแสง
                renderer.strokeColor = UIColor.systemBlue                        // ขอบสีฟ้า
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
