import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {

    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published private(set) var region: MKCoordinateRegion
    @Published var userLocation: CLLocation?
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var isMapReady = false
    @Published var showOnboarding = true

    private let locationService: LocationServiceProtocol
    private let sendLocationUseCase: SendLocationUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        locationService: LocationServiceProtocol = LocationService(),
        sendLocationUseCase: SendLocationUseCaseProtocol
    ) {
        self.locationService = locationService
        self.sendLocationUseCase = sendLocationUseCase

        // ✅ initial region เท่านั้น
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        bind()
    }

    private func bind() {
        locationService.authorizationStatusPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$status)

        locationService.locationPublisher
            .removeDuplicates()
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] location in
                guard let self else { return }

                self.userLocation = location

                // ❌ ไม่ update region แล้ว
                // ให้ map control ตัวเอง
            }
            .store(in: &cancellables)
    }

    func prepareMap() {
        // ไม่ต้องทำอะไรแล้ว
    }

    func onMapReady() {
        isMapReady = true
    }

    func onUserTap(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
    }
}
