import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    func requestAuthorization()
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager = CLLocationManager()

    @Published private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private var userLocation: CLLocation?

    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        $authorizationStatus.eraseToAnyPublisher()
    }

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        $userLocation
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
}

