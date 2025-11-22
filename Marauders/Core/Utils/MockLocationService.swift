import CoreLocation
import Combine

class MockLocationService: LocationServiceProtocol {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?
    var requestAuthorizationCalled = false

    init(status: CLAuthorizationStatus = .authorizedWhenInUse,
         location: CLLocation? = nil) {
        self.authorizationStatus = status
        self.userLocation = location
            }

    func requestAuthorization() {
        requestAuthorizationCalled = true
        // สามารถ simulate การอนุญาตหรือ denied
    }
}
