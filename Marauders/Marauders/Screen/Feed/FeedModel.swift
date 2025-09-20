import Foundation
import CoreLocation

struct Post: Identifiable, Codable {
    let id: String
    let videoUrl: URL
    let latitude: Double
    let longitude: Double
}
