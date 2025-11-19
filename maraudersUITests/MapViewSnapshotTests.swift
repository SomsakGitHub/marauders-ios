//import XCTest
//import SwiftUI
//import SnapshotTesting
//@testable import MyApp
//
//final class MapViewSnapshotTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        isRecording = false // true → สร้าง snapshot ใหม่
//    }
//
//    func testMapViewWithUserLocation() {
//        let mockLocation = CLLocation(latitude: 13.7563, longitude: 100.5018)
//        let mockService = MockLocationService(location: mockLocation)
//        let vm = MapViewModel(locationService: mockService)
//        vm.onMapReady()
//
//        let view = MapView(viewModel: vm)
//            .frame(width: 375, height: 812)
//
//        assertSnapshot(matching: view, as: .image)
//    }
//
//    func testMapViewWithoutLocation() {
//        let mockService = MockLocationService(location: nil)
//        let vm = MapViewModel(locationService: mockService)
//        vm.onMapReady()
//
//        let view = MapView(viewModel: vm)
//            .frame(width: 375, height: 812)
//
//        assertSnapshot(matching: view, as: .image)
//    }
//}
