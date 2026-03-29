import CoreLocation
import Combine

enum LocationError: Error {
    case permissionDenied
}

protocol LocationServiceProtocol {
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    func requestPermission() async throws -> CLAuthorizationStatus
    var authorizationStatus: CLAuthorizationStatus { get }
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLAuthorizationStatus, Error>?
    
    @Published internal var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private var userLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        $authorizationStatus.eraseToAnyPublisher()
    }
    
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        $userLocation
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    func requestPermission() async throws -> CLAuthorizationStatus {

        let status = manager.authorizationStatus

        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return status
        }

        if status == .denied || status == .restricted {
            throw LocationError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in

            self.continuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        authorizationStatus = manager.authorizationStatus
        manager.startUpdatingLocation()

        guard let continuation else { return }

        switch authorizationStatus {

        case .authorizedAlways, .authorizedWhenInUse:
            continuation.resume(returning: authorizationStatus)

        case .denied, .restricted:
            continuation.resume(throwing: LocationError.permissionDenied)

        default:
            break
        }

        self.continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
}
