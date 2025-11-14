import SwiftUI
import Combine
import CoreLocation

class MapViewModel: ObservableObject {

    @Published var showOnboarding = true
    @Published var isMapReady = false
    @Published var selectedCoordinate: CLLocationCoordinate2D?

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var status: CLAuthorizationStatus = .notDetermined

    private var cancellables = Set<AnyCancellable>()

    let locationService: LocationService

    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
        
        // Bind service → VM
        locationService.$authorizationStatus
            .receive(on: .main)
            .assign(to: &$status)
        
        locationService.$userLocation
            .compactMap { $0?.coordinate }
            .sink { [weak self] coordinate in
                self?.region.center = coordinate
            }
            .store(in: &cancellables)
    }

    func requestPermission() {
        locationService.requestAuthorization()
    }

    func onMapReady() {
        isMapReady = true
    }

    func onUserTap(_ coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
    }
}
