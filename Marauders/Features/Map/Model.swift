import Foundation
import CoreLocation

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

struct VideoLocation: Identifiable {
    let id: UUID
    let title: String
    let coordinate: CLLocationCoordinate2D
    let views: Int
    let thumbnail: String
}

final class MockVideoRepository: VideoRepositoryProtocol {

    func getPopularVideos() async throws -> [VideoLocation] {

        [
            VideoLocation(
                id: UUID(),
                title: "Street Food",
                coordinate: .init(
                    latitude: 13.7563,
                    longitude: 100.5018
                ),
                views: 250000,
                thumbnail: ""
            ),

            VideoLocation(
                id: UUID(),
                title: "Night Market",
                coordinate: .init(
                    latitude: 13.7535,
                    longitude: 100.4940
                ),
                views: 120000,
                thumbnail: ""
            ),

            VideoLocation(
                id: UUID(),
                title: "Temple Tour",
                coordinate: .init(
                    latitude: 13.7510,
                    longitude: 100.4920
                ),
                views: 500000,
                thumbnail: ""
            )
        ]
    }
}
