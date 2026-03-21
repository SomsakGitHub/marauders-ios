@testable import Marauders
import AVFoundation
import XCTest

@MainActor
final class FeedViewModelTests: XCTestCase {

    // MARK: - Load

    func test_loadNextPage_appendsVideos() async {
        let useCase = MockFetchVideoUseCase()
        let sut = FeedViewModel(fetchVideoUseCase: useCase)

        await sut.loadNextPage()

        XCTAssertEqual(sut.videos.count, 2)
        XCTAssertEqual(useCase.callCount, 1)
    }

    func test_loadNextPage_multipleCalls_appendsMoreVideos() async {
        let useCase = MockFetchVideoUseCase()
        let sut = FeedViewModel(fetchVideoUseCase: useCase)

        await sut.loadNextPage()
        await sut.loadNextPage()

        XCTAssertEqual(sut.videos.count, 4)
        XCTAssertEqual(useCase.callCount, 2)
    }

    // MARK: - Concurrency

    func test_loadNextPage_whileLoading_shouldNotDuplicateCall() async {
        let useCase = MockFetchVideoUseCase()
        useCase.delay = 200_000_000

        let sut = FeedViewModel(fetchVideoUseCase: useCase)

        async let first = sut.loadNextPage()
        async let second = sut.loadNextPage()

        _ = await (first, second)

        XCTAssertEqual(useCase.callCount, 1)
    }

    // MARK: - Cache

    func test_loadNextPage_respectsMaxCache() async {
        let useCase = MockFetchVideoUseCase()
        let sut = FeedViewModel(fetchVideoUseCase: useCase)

        for _ in 0..<20 {
            await sut.loadNextPage()
        }

        XCTAssertLessThanOrEqual(sut.videos.count, 30)
    }
    
    func test_didFocusVideo_triggersPagination() async {

        let useCase = MockFetchVideoUseCase()
        let viewModel = FeedViewModel(fetchVideoUseCase: useCase)

        await viewModel.loadNextPage()

        let lastID = viewModel.videos.last!.id

        viewModel.didFocusVideo(id: lastID)

        // ถ้า logic ถูก จะเรียก loadNextPage
    }
    
    func test_didFocusVideo_preloadPrevious_whenScrollUp() async {
        let useCase = MockFetchVideoUseCase()
        let videoEngine = MockVideoEngine()
        let viewModel = FeedViewModel(
            fetchVideoUseCase: useCase,
            videoEngine: videoEngine
        )

        await viewModel.loadNextPage()
        let videos = viewModel.videos

        viewModel.didFocusVideo(id: videos[1].id) // ลง
        viewModel.didFocusVideo(id: videos[0].id) // ขึ้น

        XCTAssertEqual(videoEngine.preloadedVideo?.id, videos[safe: -1]?.id)
    }
}

@MainActor
final class MockFetchVideoUseCase: FetchVideoUseCaseProtocol {

    private(set) var callCount = 0

    var delay: UInt64 = 0
    var result: Result<FeedResponse, Error> = .success(TestData.feedResponse)

    func execute() async throws -> FeedResponse {
        callCount += 1

        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }

        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

final class MockVideoEngine: VideoEngineProtocol {

    var state: PlaybackState = .idle
    var player: PlayerProtocol = AVPlayer()

    private(set) var playedVideo: VideoDTO?
    private(set) var preloadedVideo: VideoDTO?

    func play(video: VideoDTO) {
        playedVideo = video
    }

    func preload(video: VideoDTO?) {
        preloadedVideo = video
    }
}
