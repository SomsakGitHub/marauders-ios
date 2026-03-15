import CoreLocation
import Combine

enum LocationError: Error {
    case permissionDenied
}

protocol LocationServiceProtocol {

    func requestPermission() async throws -> CLAuthorizationStatus
    var authorizationStatus: CLAuthorizationStatus { get }

}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLAuthorizationStatus, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
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

        guard let continuation else { return }

        let status = manager.authorizationStatus

        switch status {

        case .authorizedAlways, .authorizedWhenInUse:
            continuation.resume(returning: status)

        case .denied, .restricted:
            continuation.resume(throwing: LocationError.permissionDenied)

        default:
            break
        }

        self.continuation = nil
    }
}
