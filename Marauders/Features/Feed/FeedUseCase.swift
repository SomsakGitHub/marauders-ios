import MapKit

protocol FetchVideoUseCaseProtocol {
    func execute() async throws -> FeedResponse
}

final class DefaultFetchVideoUseCase: FetchVideoUseCaseProtocol {
    private let repo: FeedRepositoryProtocol

    init(repo: FeedRepositoryProtocol) {
        self.repo = repo
    }

    func execute() async throws -> FeedResponse {
        try await repo.fetchVideo()
    }
    
}
