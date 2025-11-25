import Testing
import CoreLocation
import MapKit
import Combine
@testable import Marauders

struct MapViewModelTests {

    @MainActor
    @Test
    func testInitUpdatesStatusAndRegion() async throws {
        // GIVEN
        let mockLocation = CLLocation(latitude: MapViewModel.latitude, longitude: MapViewModel.longitude)
        let mock = MockLocationService(
            status: .authorizedWhenInUse,
            location: mockLocation
        )

        // WHEN
        let vm = MapViewModel(locationService: mock)

        // THEN
        #expect(vm.status == .notDetermined)
        #expect(vm.region.center.latitude == MapViewModel.latitude)
        #expect(vm.region.center.longitude == MapViewModel.longitude)
        
//        let name: String? = nil
//        print(name!)      // <- force_unwrapping
    }

    @MainActor
    @Test
    func testRegionUpdatesWhenLocationChanges() async throws {
        // GIVEN: mock location service with initial values
        let mock = MockLocationService(
            status: .authorizedWhenInUse,
            location: nil
        )

        let vm = MapViewModel(locationService: mock)

        // initial should not match new location
        #expect(vm.region.center.latitude != 10.0)
        #expect(vm.region.center.longitude != 20.0)

        // WHEN: update mock location and send objectWillChange
        mock.userLocation = CLLocation(latitude: 10.0, longitude: 20.0)
        mock.objectWillChange.send()   // ← สำคัญมาก เพื่อ trigger sink()

        // THEN: region must update
        #expect(vm.region.center.latitude == 10.0)
        #expect(vm.region.center.longitude == 20.0)
    }


    @MainActor
    @Test
    func testRequestPermissionCallsService() async throws {
        // GIVEN
        let mock = MockLocationService()
        let vm = MapViewModel(locationService: mock)

        // WHEN
        vm.requestPermission()

        // THEN
        #expect(mock.requestAuthorizationCalled == true)
    }

    @MainActor
    @Test
    func testOnMapReadySetsFlag() async throws {
        // GIVEN
        let vm = MapViewModel(locationService: MockLocationService())

        // WHEN
        vm.onMapReady()

        // THEN
        #expect(vm.isMapReady == true)
    }

    @MainActor
    @Test
    func testOnUserTapUpdatesSelectedCoordinate() async throws {
        // GIVEN
        let vm = MapViewModel(locationService: MockLocationService())
        let tapCoordinate = CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0)

        // WHEN
        vm.onUserTap(tapCoordinate)

        // THEN
        #expect(vm.selectedCoordinate?.latitude == 1.0)
        #expect(vm.selectedCoordinate?.longitude == 2.0)
    }

}
