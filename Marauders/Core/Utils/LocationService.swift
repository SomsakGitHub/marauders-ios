import CoreLocation
import Combine

protocol LocationServiceProtocol: AnyObject, ObservableObject {
    var authorizationStatus: CLAuthorizationStatus { get set }
    var userLocation: CLLocation? { get set }

    var objectWillChange: ObservableObjectPublisher { get }

    func requestAuthorization()
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
}
