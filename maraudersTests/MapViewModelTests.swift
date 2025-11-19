import Testing
import CoreLocation
import Combine
import MapKit
@testable import Marauders

@MainActor
struct MapViewModelTests {

    @Test("Region should update when user location changes")
    func regionUpdatesOnLocationChange() async throws {
        let mockLocation = CLLocation(latitude: 13.7563, longitude: 100.5018)
        let mockService = MockLocationService(location: mockLocation)
        let vm = MapViewModel(locationService: mockService)

        #expect(vm.region.center.latitude == MapViewModel.latitude)
        #expect(vm.region.center.longitude == MapViewModel.longitude)

        // simulate update
        mockService.userLocation = mockLocation
        mockService.objectWillChange.send()

        #expect(vm.region.center.latitude == 13.7563)
        #expect(vm.region.center.longitude == 100.5018)
    }

    @Test("User tap should update selected coordinate")
    func onUserTapUpdatesSelection() async throws {
        let vm = MapViewModel(locationService: MockLocationService())
        let coord = CLLocationCoordinate2D(latitude: 14.0, longitude: 101.0)

        vm.onUserTap(coord)

        #expect(vm.selectedCoordinate?.latitude == 14.0)
        #expect(vm.selectedCoordinate?.longitude == 101.0)
    }
}
