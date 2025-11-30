import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - UI State
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocation?
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var isMapReady = false
    @Published var showOnboarding = true

    // MARK: - Dependencies
    private let locationService: LocationServiceProtocol
    private let updateRegionUseCase: MapUseCaseProtocol
    private let sendLocationUseCase: SendLocationUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        locationService: LocationServiceProtocol = LocationService(),
        updateRegionUseCase: MapUseCaseProtocol = MapUseCase(),
        sendLocationUseCase: SendLocationUseCaseProtocol
    ) {
        self.locationService = locationService
        self.updateRegionUseCase = updateRegionUseCase
        self.sendLocationUseCase = sendLocationUseCase

        self.region = updateRegionUseCase.updateRegion(from: nil)

        bind()
    }

    // MARK: - Bind services
    private func bind() {
        locationService.authorizationStatusPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$status)

        locationService.locationPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self else { return }
                self.userLocation = location
                self.region = self.updateRegionUseCase.updateRegion(from: location)

                Task {
                    let dto = LocationDTO(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        accuracy: location.horizontalAccuracy,
                        timestamp: Date()
                    )
                    try? await self.sendLocationUseCase.execute(dto: dto)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - User Actions
    func requestPermission() {
        locationService.requestAuthorization()
    }

    func onMapReady() {
        isMapReady = true
    }

    func onUserTap(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
    }
}
