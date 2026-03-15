import Foundation

protocol FeedRepositoryProtocol {
    func fetchVideo(page: Int) async throws -> FeedResponse
}

final class FeedRepository: FeedRepositoryProtocol {
    
    private let service: FeedNetworkServiceProtocol

    init(service: FeedNetworkServiceProtocol) {
        self.service = service
    }
    
    func fetchVideo(page: Int) async throws -> FeedResponse {
        try await service.fetchVideo()
    }

//    func fetch(page: Int) async throws -> [VideoItem] {
//
//        guard let url = URL(string: "http://192.168.1.164:8080/v1/videos/feed") else {
//            throw URLError(.badURL)
//        }
//
//        let (data, _) = try await URLSession.shared.data(from: url)
//
//        let response = try JSONDecoder().decode(FeedResponse.self, from: data)
//        
//        print("response=>", response)
//
//        let items: [VideoItem] = response.data.compactMap { dto -> VideoItem? in
//            guard let url = URL(string: dto.videoURL) else { return nil }
//            return VideoItem(url: url)
//        }
//
//        return items
//    }
}

//protocol LocationRepositoryProtocol {
//    func updateLocation(_ dto: LocationDTO) async throws
//}
//
//final class LocationRepository: LocationRepositoryProtocol {
//    private let service: LocationNetworkServiceProtocol
//
//    init(service: LocationNetworkServiceProtocol) {
//        self.service = service
//    }
//
//    func updateLocation(_ dto: LocationDTO) async throws {
//        try await service.sendLocation(dto)
//    }
//}

//import Foundation
//
//protocol FeedRepositoryProtocol {
//    func fetch(page: Int) async throws -> [VideoItem]
//}
//
//final class FeedRepository: FeedRepositoryProtocol {
//
//    func fetch(page: Int) async throws -> [VideoItem] {
//
//        try await Task.sleep(nanoseconds: 800_000_000)
//
//        let resources = [
//            "oneDancing",
//            "fireworks",
//            "selfie",
//            "threeDancing"
//        ]
//
//        return (0..<5).flatMap { _ in
//            resources.compactMap { name in
//                guard let url = Bundle.main.url(forResource: name, withExtension: "mp4") else {
//                    return nil
//                }
//                return VideoItem(url: url)
//            }
//        }
//    }
//}

