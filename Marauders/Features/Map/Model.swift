import Foundation

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct LocationDTO: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let timestamp: Date
}
