import Foundation

protocol FeedRepositoryProtocol {
    func fetchVideo(cursor: String?) async throws -> FeedResponse
    func likeVideo(videoId: String) async throws
    func unlikeVideo(videoId: String) async throws
}

final class FeedRepository: FeedRepositoryProtocol {
    
    private let service: FeedNetworkServiceProtocol

    init(service: FeedNetworkServiceProtocol) {
        self.service = service
    }
    
    func fetchVideo(cursor: String?) async throws -> FeedResponse {
        try await service.fetchVideo(cursor: cursor)
    }

    func likeVideo(videoId: String) async throws {
        try await service.likeVideo(videoId: videoId)
    }

    func unlikeVideo(videoId: String) async throws {
        try await service.unlikeVideo(videoId: videoId)
    }
}

