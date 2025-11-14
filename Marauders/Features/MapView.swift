//import SwiftUI
//import MapKit
//import Combine
//
//// View หลักที่แสดงแผนที่
//struct MapView: View {
//    var body: some View {
//        CustomMap() // เรียกใช้ Custom UIViewRepresentable map
//    }
//}
//
//#Preview {
//    MapView()
//}
//
//// MARK: - CustomMap: ใช้ UIViewRepresentable เพื่อเชื่อม MKMapView เข้ากับ SwiftUI
//struct CustomMap: UIViewRepresentable {
//    // พิกัดที่เลือก (optional) สำหรับเก็บจุดที่ user แตะ
//    var coordinate: CLLocationCoordinate2D?
//    
//    // ตัวจัดการตำแหน่งผู้ใช้
//    var locationManager = LocationManager()
//
//    // MARK: - Coordinator สำหรับจัดการ delegate & gesture
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // MARK: - สร้าง UIView (MKMapView)
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator       // ตั้ง delegate ให้ Coordinator
//        mapView.showsUserLocation = true             // แสดงจุดตำแหน่งผู้ใช้บนแผนที่
//        
//        // ตรวจสอบสถานะการอนุญาตตำแหน่ง
//        switch locationManager.manager.authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            // ✅ ถ้ามีสิทธิ์แล้ว
//            if let location = locationManager.manager.location?.coordinate {
//                // ✅ มีตำแหน่งผู้ใช้ → ขยับกล้องไปจุดนั้น
//                let region = MKCoordinateRegion(
//                    center: location,
//                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//                )
//                mapView.setRegion(region, animated: true)
//            } else {
//                // ⏳ ยังไม่มีตำแหน่ง (เช่น เพิ่งอนุญาตแต่ยังไม่ได้ค่าพิกัด)
//                locationManager.manager.requestLocation()
//            }
//            
//        case .notDetermined:
//            // ❌ ยังไม่ขอ → ขออนุญาต
//            locationManager.manager.requestWhenInUseAuthorization()
//            
//        case .restricted, .denied:
//            // ⚠️ ไม่มีสิทธิ์เข้าถึงตำแหน่ง
//            print("❌ Location access denied or restricted.")
//            // ❌ ผู้ใช้ปฏิเสธ / ถูกจำกัด → เปิด Settings เพื่อเปิดสิทธิ์ใหม่
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                showLocationSettingsAlert()
//            }
//            
//        @unknown default:
//            break
//        }
//        
//        // เพิ่ม gesture recognizer สำหรับแตะบนแผนที่
//        let gesture = UITapGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleTap(_:))
//        )
//        mapView.addGestureRecognizer(gesture)
//        
//        return mapView
//    }
//    
//    // MARK: - เปิด Settings ให้ผู้ใช้ไปอนุญาตใหม่
//    func showLocationSettingsAlert() {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let rootVC = scene.windows.first?.rootViewController else { return }
//        
//        let alert = UIAlertController(
//            title: "ไม่สามารถเข้าถึงตำแหน่งได้",
//            message: "กรุณาเปิดสิทธิ์การเข้าถึงตำแหน่งใน Settings เพื่อใช้งานฟีเจอร์นี้",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "เปิด Settings", style: .default, handler: { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel))
//        rootVC.present(alert, animated: true)
//    }
//
//    // MARK: - อัปเดต UIView (กรณี SwiftUI state เปลี่ยน)
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // อัปเดต region ทุกครั้งที่มีตำแหน่งใหม่
//        if let location = locationManager.manager.location?.coordinate {
//            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            uiView.setRegion(region, animated: true)
//        }
//    }
//
//    // MARK: - Coordinator Class
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: CustomMap
//
//        init(_ parent: CustomMap) {
//            self.parent = parent
//        }
//
//        // MARK: - Gesture handler เมื่อผู้ใช้แตะบนแผนที่
//        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            let location = gesture.location(in: gesture.view) // แปลงตำแหน่งแตะให้เป็น CGPoint
//            
//            if let mapView = gesture.view as? MKMapView {
//                // แปลงตำแหน่ง CGPoint → พิกัด CLLocationCoordinate2D
//                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
//                
//                print("coordinate.latitude => \(coordinate.latitude)")
//                print("coordinate.longitude => \(coordinate.longitude)")
//                
//                // เก็บพิกัดไว้ใน parent (CustomMap)
//                parent.coordinate = coordinate
//
//                // ลบ pin และ overlay เดิมก่อนวาดใหม่
//                mapView.removeAnnotations(mapView.annotations)
//                mapView.removeOverlays(mapView.overlays)
//                
//                // ✅ วาง pin ใหม่ในจุดที่แตะ
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                mapView.addAnnotation(annotation)
//                
//                // ✅ วาดวงกลมรัศมีรอบจุดแตะ (1 km)
//                let circle = MKCircle(center: coordinate, radius: 1000)
//                mapView.addOverlay(circle)
//            }
//        }
//        
//        // MARK: - สร้าง renderer สำหรับ overlay (เช่น วงกลม)
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let circleOverlay = overlay as? MKCircle {
//                let renderer = MKCircleRenderer(circle: circleOverlay)
//                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3) // พื้นโปร่งแสง
//                renderer.strokeColor = UIColor.systemBlue                        // ขอบสีฟ้า
//                renderer.lineWidth = 2
//                return renderer
//            }
//            return MKOverlayRenderer()
//        }
//    }
//}
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    
//    let manager = CLLocationManager()
//    
//    @Published var location: CLLocation?
//    
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    func requestLocation() {
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
//        manager.requestLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.last
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
//    }
//}
