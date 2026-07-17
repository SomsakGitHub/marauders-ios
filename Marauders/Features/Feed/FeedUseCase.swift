import MapKit

protocol FetchVideoUseCaseProtocol {
    func execute(cursor: String?) async throws -> FeedResponse
}

final class DefaultFetchVideoUseCase: FetchVideoUseCaseProtocol {
    
    private let repo: FeedRepositoryProtocol

    init(repo: FeedRepositoryProtocol) {
        self.repo = repo
    }
    
    func execute(cursor: String?) async throws -> FeedResponse {
        try await repo.fetchVideo(cursor: cursor)
    }
}

protocol LikeVideoUseCaseProtocol {
    func like(videoId: String) async throws
    func unlike(videoId: String) async throws
}

final class DefaultLikeVideoUseCase: LikeVideoUseCaseProtocol {

    private let repo: FeedRepositoryProtocol

    init(repo: FeedRepositoryProtocol) {
        self.repo = repo
    }

    func like(videoId: String) async throws {
        try await repo.likeVideo(videoId: videoId)
    }

    func unlike(videoId: String) async throws {
        try await repo.unlikeVideo(videoId: videoId)
    }
}

