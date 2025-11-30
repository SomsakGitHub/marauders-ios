import Testing
import Combine
import CoreLocation
import MapKit
@testable import Marauders

@Suite("MapViewModel Full Coverage Tests")
@MainActor
final class MapViewModelTests {
    
    final class MockLocationService: LocationServiceProtocol {

        let authSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
        let locSubject = PassthroughSubject<CLLocation, Never>()

        private(set) var requestAuthorizationCalled = false

        var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
            authSubject.eraseToAnyPublisher()
        }

        var locationPublisher: AnyPublisher<CLLocation, Never> {
            locSubject
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        func requestAuthorization() {
            requestAuthorizationCalled = true
        }
    }

    @MainActor
    final class MockUpdateRegionUseCase: MapUseCaseProtocol {
        private(set) var receivedLocation: CLLocation?
        var returnedRegion = MKCoordinateRegion(
            center: .init(latitude: 1, longitude: 1),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        func updateRegion(from location: CLLocation?) -> MKCoordinateRegion {
            receivedLocation = location
            return returnedRegion
        }
    }

    @MainActor
    final class MockSendLocationUseCase: SendLocationUseCaseProtocol {

        private(set) var called = false
        private(set) var received: LocationDTO?

        func execute(dto: LocationDTO) async throws {
            called = true
            received = dto
        }
    }


    // MARK: Init
    @Test("init → region เริ่มต้นควรตรงกับ useCase.updateRegion(nil)")
    func testInitialRegion() {
        let mockLocation = MockLocationService()
        let mockUseCase = MockUpdateRegionUseCase()
        let sendUseCase = MockSendLocationUseCase()

        mockUseCase.returnedRegion = MKCoordinateRegion(
            center: .init(latitude: 99, longitude: 55),
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )

        let vm = MapViewModel(
            locationService: mockLocation,
            updateRegionUseCase: mockUseCase,
            sendLocationUseCase: sendUseCase
        )

        #expect(vm.region.center.latitude == 99)
        #expect(vm.region.center.longitude == 55)
    }

    // MARK: Authorization Binding
    @Test("Auth → status ต้องอัปเดตเมื่อ publisher ส่งค่า")
    func testAuthorizationBinding() async throws {
        let mockLocation = MockLocationService()
        let vm = MapViewModel(
            locationService: mockLocation,
            updateRegionUseCase: MockUpdateRegionUseCase(),
            sendLocationUseCase: MockSendLocationUseCase()
        )

        mockLocation.authSubject.send(.authorizedAlways)

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.status == .authorizedAlways)
    }

    // MARK: Location Binding + Region Update + API call
    @Test("Location → userLocation, region, sendLocationUseCase.execute() ต้องถูกเรียก")
    func testLocationBindingFullFlow() async throws {
        let mockLocation = MockLocationService()
        let mockRegion = MockUpdateRegionUseCase()
        let sendUseCase = MockSendLocationUseCase()

        let vm = MapViewModel(
            locationService: mockLocation,
            updateRegionUseCase: mockRegion,
            sendLocationUseCase: sendUseCase
        )

        let loc = CLLocation(latitude: 10, longitude: 20)
        mockRegion.returnedRegion = MKCoordinateRegion(
            center: .init(latitude: 99, longitude: 77),
            span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        mockLocation.locSubject.send(loc)

        try await Task.sleep(nanoseconds: 150_000_000)

        #expect(vm.userLocation?.coordinate.latitude == 10)
        #expect(mockRegion.receivedLocation === loc)
        #expect(vm.region.center.latitude == 99)
        #expect(sendUseCase.called == true)
        #expect(sendUseCase.received?.latitude == 10)
        #expect(sendUseCase.received?.longitude == 20)
    }

    // MARK: Request Permission
    @Test("requestPermission → locationService.requestAuthorization() ต้องถูกเรียก")
    func testRequestPermission() {
        let mockLocation = MockLocationService()
        let vm = MapViewModel(
            locationService: mockLocation,
            updateRegionUseCase: MockUpdateRegionUseCase(),
            sendLocationUseCase: MockSendLocationUseCase()
        )

        vm.requestPermission()

        #expect(mockLocation.requestAuthorizationCalled == true)
    }

    // MARK: Map Ready
    @Test("onMapReady → isMapReady = true")
    func testMapReady() {
        let vm = MapViewModel(
            locationService: MockLocationService(),
            updateRegionUseCase: MockUpdateRegionUseCase(),
            sendLocationUseCase: MockSendLocationUseCase()
        )

        vm.onMapReady()

        #expect(vm.isMapReady == true)
    }

    // MARK: User Tap
    @Test("onUserTap → selectedCoordinate ต้องถูกตั้งค่า")
    func testUserTap() {
        let vm = MapViewModel(
            locationService: MockLocationService(),
            updateRegionUseCase: MockUpdateRegionUseCase(),
            sendLocationUseCase: MockSendLocationUseCase()
        )

        let coord = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        vm.onUserTap(coord)

        #expect(vm.selectedCoordinate?.latitude == 1)
        #expect(vm.selectedCoordinate?.longitude == 2)
    }

    // MARK: Onboarding (เผื่อ logic ในอนาคต)
    @Test("showOnboarding default = true")
    func testOnboardingDefault() {
        let vm = MapViewModel(
            locationService: MockLocationService(),
            updateRegionUseCase: MockUpdateRegionUseCase(),
            sendLocationUseCase: MockSendLocationUseCase()
        )

        #expect(vm.showOnboarding == true)
    }
}
