import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {

    @Published var status: CLAuthorizationStatus = .notDetermined
    private(set) var region: MKCoordinateRegion
    private(set) var userLocation: CLLocation?
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var isMapReady = false
    @Published var showOnboarding = true
    private var hasCenteredToUser = false
    @Published var videos: [VideoLocation] = []

    private let locationService: LocationServiceProtocol
    private let sendLocationUseCase: SendLocationUseCaseProtocol
    private let popularVideosUseCase: GetPopularVideosUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        locationService: LocationServiceProtocol = LocationService(),
        sendLocationUseCase: SendLocationUseCaseProtocol,
        popularVideosUseCase: GetPopularVideosUseCaseProtocol
    ) {

        self.locationService = locationService
        self.sendLocationUseCase = sendLocationUseCase
        self.popularVideosUseCase = popularVideosUseCase

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

                // ✅ center map ครั้งแรกเท่านั้น
                if !self.hasCenteredToUser {

                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: .init(
                            latitudeDelta: 0.01,
                            longitudeDelta: 0.01
                        )
                    )

                    self.hasCenteredToUser = true
                }
            }
            .store(in: &cancellables)
    }

    func onMapReady() {
        isMapReady = true
        
        loadPopularVideos()
    }

    func onUserTap(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
    }
    
    func loadPopularVideos() {

        Task {

            do {

                videos = try await popularVideosUseCase.execute()

            } catch {

                print(error)
            }

        }

    }
}
