import CoreLocation
import Combine

class MockLocationService: LocationServiceProtocol {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?

    init(status: CLAuthorizationStatus = .authorizedWhenInUse,
         location: CLLocation? = nil) {
        self.authorizationStatus = status
        self.userLocation = location
    }

    func requestAuthorization() {
        // สามารถ simulate การอนุญาตหรือ denied
    }
}
