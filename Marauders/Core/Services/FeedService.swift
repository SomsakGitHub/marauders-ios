protocol FeedNetworkServiceProtocol {
    func fetchVideo(cursor: String?) async throws -> FeedResponse
}

final class FeedNetworkService: FeedNetworkServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func fetchVideo(cursor: String?) async throws -> FeedResponse {
        try await client.send(LocationAPI.fetchVideo)
    }
}
