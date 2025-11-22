//import XCTest
//import SwiftUI
//import SnapshotTesting
//import CoreLocation
//@testable import Marauders
//
//final class MapViewSnapshotTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        isRecording = false // true → สร้าง snapshot ใหม่
//    }
//
//    @MainActor
//    func testMapViewWithUserLocation() {
//        let mockLocation = CLLocation(latitude: 13.7563, longitude: 100.5018)
//        let mockService = MockLocationService(location: mockLocation)
//        let vm = MapViewModel(locationService: mockService)
//        vm.onMapReady()
//
//        let view = MapView()
//            .frame(width: 375, height: 812)
//
//        assertSnapshot(matching: view, as: .image)
//    }
//
//    @MainActor
//    func testMapViewWithoutLocation() {
//        let mockService = MockLocationService(location: nil)
//        let vm = MapViewModel(locationService: mockService)
//        vm.onMapReady()
//
//        let view = MapView()
//            .frame(width: 375, height: 812)
//
//        assertSnapshot(matching: view, as: .image)
//    }
//}
