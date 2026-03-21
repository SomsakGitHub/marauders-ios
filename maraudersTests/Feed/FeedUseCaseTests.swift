@testable import Marauders
import XCTest

@MainActor
final class FeedUseCaseTests: XCTestCase {

    func test_execute_returnsDecodedFeedResponse() async throws {
        // Arrange
        let repo = MockFeedRepository()
        let sut = DefaultFetchVideoUseCase(repo: repo)

        // Act
        let response = try await sut.execute()

        // Assert
        XCTAssertEqual(response.data.count, 2)
        XCTAssertEqual(response.page, 1)
        XCTAssertTrue(response.hasNext)
        XCTAssertEqual(repo.fetchCallCount, 1)
    }
}

final class MockFeedRepository: FeedRepositoryProtocol {

    private(set) var fetchCallCount = 0

    func fetchVideo() async throws -> FeedResponse {
        fetchCallCount += 1
        return TestData.feedResponse
    }
}
