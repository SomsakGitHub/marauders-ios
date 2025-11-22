import SwiftUI
import Combine
import CoreLocation
import MapKit

class MapViewModel: ObservableObject {
    
    static let latitude = 13.63164
    static let longitude = 13.63164
    
    @Published var showOnboarding = true
    @Published var isMapReady = false
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var status: CLAuthorizationStatus = .notDetermined

    private var cancellables = Set<AnyCancellable>()
    private let locationService: LocationServiceProtocol

    init(locationService: LocationServiceProtocol = LocationService()) {
        self.locationService = locationService

        // bind locationService -> viewModel
        locationService.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.status = locationService.authorizationStatus
                if let coord = locationService.userLocation?.coordinate {
                    self.region.center = coord
                }
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

