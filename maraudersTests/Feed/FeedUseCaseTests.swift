@testable import Marauders
import XCTest

@MainActor
final class FeedUseCaseTests: XCTestCase {

    func test_execute_returnsDecodedFeedResponse() async throws {
        // Arrange
        let repo = MockFeedRepository()
        let sut = DefaultFetchVideoUseCase(repo: repo)

        // Act
        let response = try await sut.execute(cursor: nil)

        // Assert
        XCTAssertEqual(response.videos.count, 2)
        XCTAssertNotNil(response.nextCursor)
        XCTAssertEqual(repo.fetchCallCount, 1)
    }
}

final class MockFeedRepository: FeedRepositoryProtocol {

    private(set) var fetchCallCount = 0

    func fetchVideo(cursor: String?) async throws -> FeedResponse {
        fetchCallCount += 1
        return TestData.feedResponse
    }

    func likeVideo(videoId: String) async throws {}

    func unlikeVideo(videoId: String) async throws {}
}
