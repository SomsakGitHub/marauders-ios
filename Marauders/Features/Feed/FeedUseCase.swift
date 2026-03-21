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
    
//    func execute() async throws -> FeedResponse {
//        guard let url = Bundle.main.url(forResource: "fireworks", withExtension: "mp4") else {
//            throw NSError(domain: "VideoError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Video not found"])
//        }
//        
//        let video = VideoDTO(
//            id: UUID().uuidString,
//            title: "Local Video",
//            description: "Video from bundle",
//            videoURL: url,
//            thumbnailURL: "", durationSeconds: 1 // หรือใส่รูป local ก็ได้
//        )
//        
//        return FeedResponse(
//            data: [video],
//            page: 1,
//            pageSize: 1,
//            totalCount: 1,
//            totalPages: 1,
//            hasNext: false,
//            hasPrev: false
//        )
//    }
}
