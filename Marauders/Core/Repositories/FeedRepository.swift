import Foundation

protocol FeedRepositoryProtocol {
    func fetchVideo() async throws -> FeedResponse
}

final class FeedRepository: FeedRepositoryProtocol {
    
    private let service: FeedNetworkServiceProtocol

    init(service: FeedNetworkServiceProtocol) {
        self.service = service
    }
    
    func fetchVideo() async throws -> FeedResponse {
        try await service.fetchVideo()
    }
}

