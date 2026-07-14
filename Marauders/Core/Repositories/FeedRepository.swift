import Foundation

protocol FeedRepositoryProtocol {
    func fetchVideo(cursor: String?) async throws -> FeedResponse
}

final class FeedRepository: FeedRepositoryProtocol {
    
    private let service: FeedNetworkServiceProtocol

    init(service: FeedNetworkServiceProtocol) {
        self.service = service
    }
    
    func fetchVideo(cursor: String?) async throws -> FeedResponse {
        try await service.fetchVideo(cursor: cursor)
    }
}

