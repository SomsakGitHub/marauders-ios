protocol FeedNetworkServiceProtocol {
    func fetchVideo(cursor: String?) async throws -> FeedResponse
    func likeVideo(videoId: String) async throws
    func unlikeVideo(videoId: String) async throws
}

final class FeedNetworkService: FeedNetworkServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func fetchVideo(cursor: String?) async throws -> FeedResponse {
        try await client.send(LocationAPI.fetchVideo)
    }

    func likeVideo(videoId: String) async throws {
        try await client.sendVoid(LocationAPI.likeVideo(videoId: videoId))
    }

    func unlikeVideo(videoId: String) async throws {
        try await client.sendVoid(LocationAPI.unlikeVideo(videoId: videoId))
    }
}
