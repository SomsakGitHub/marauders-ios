import CoreLocation
import SwiftData
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
//        manager.startUpdatingHeading()
        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        degrees = newHeading.trueHeading
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
//        GlobalVariable.shared.location = location
        print("location=>", location?.latitude)
        print("location=>", location?.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

@Model
class Location {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}


@propertyWrapper
struct AppStorageWrapper<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            if Value.self == String.self {
                return (container.string(forKey: key) as? Value) ?? defaultValue
            } else if Value.self == Int.self {
                return (container.integer(forKey: key) as? Value) ?? defaultValue
            } else if Value.self == Double.self {
                return (container.double(forKey: key) as? Value) ?? defaultValue
            } else if Value.self == Bool.self {
                return (container.bool(forKey: key) as? Value) ?? defaultValue
            }
            return defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

//class AppSettings: ObservableObject {
//    static let shared = AppSettings()
//    
//    @AppStorageWrapper(key: "latitude", defaultValue: 0.0)
//    var latitude: Double
//    
//    @AppStorageWrapper(key: "longitude", defaultValue: 0.0)
//    var longitude: Double
//}
