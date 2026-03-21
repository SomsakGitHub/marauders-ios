import XCTest
import AVFoundation
@testable import Marauders

@MainActor
final class VideoEngineTests: XCTestCase {

    func test_play_setsPlayingState_andStartsPlayer() async {

        let display = MockPlayer()
        let preload = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: preload
        )

        let video = VideoDTO(
            id: "1",
            title: "",
            description: "",
            videoURL: URL(string: "https://test.com/video.mp4")!,
            thumbnailURL: "",
            durationSeconds: 10
        )

        engine.play(video: video)

        XCTAssertTrue(display.didPlay)
        XCTAssertNotNil(display.currentItem)
    }
    
    func test_play_sameVideo_doesNotReplay() async {

        let display = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: MockPlayer()
        )

        let video = VideoDTO(
            id: "1",
            title: "",
            description: "",
            videoURL: URL(string: "https://test.com/video.mp4")!,
            thumbnailURL: "",
            durationSeconds: 10
        )

        engine.play(video: video)
        engine.play(video: video)

        await Task.yield() // 👈 ป้องกัน edge case

        XCTAssertEqual(display.replacedItems.count, 1)
    }
    
    func test_preload_setsPreloadPlayerItem() async {

        let preload = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: MockPlayer(),
            preloadPlayer: preload
        )

        let video = VideoDTO(
            id: "2",
            title: "",
            description: "",
            videoURL: URL(string: "https://test.com/video2.mp4")!,
            thumbnailURL: "",
            durationSeconds: 10
        )

        engine.preload(video: video)

        XCTAssertNotNil(preload.currentItem)
    }
    
    func test_swapToPreloaded_movesItemToDisplay() async {

        let display = MockPlayer()
        let preload = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: preload
        )

        let item = AVPlayerItem(url: URL(string: "https://test.com/video.mp4")!)
        preload.currentItem = item

        engine.swapToPreloaded()

        XCTAssertTrue(display.didPlay)
        XCTAssertEqual(display.currentItem, item)
    }
    
    func test_memoryWarning_clearsPreload() async {

        let preload = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: MockPlayer(),
            preloadPlayer: preload
        )

        preload.currentItem = AVPlayerItem(url: URL(string: "https://test.com")!)

        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        await Task.yield() // 👈 สำคัญ

        XCTAssertNil(preload.currentItem)
    }
    
    func test_appBackground_pausesPlayer() async {

        let display = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: MockPlayer()
        )

        NotificationCenter.default.post(
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        await Task.yield() // 👈 สำคัญมาก

        XCTAssertTrue(display.didPause)
    }
    
    func test_appForeground_resumesPlayer() async {

        let display = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: MockPlayer()
        )

        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        await Task.yield() // 👈 สำคัญมาก

        XCTAssertTrue(display.didPlay)
    }
    
    func test_loop_restartsVideo() async {

        let display = MockPlayer()

        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: MockPlayer()
        )

        NotificationCenter.default.post(
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        await Task.yield()

        XCTAssertTrue(display.didSeek)
        XCTAssertTrue(display.didPlay)
    }
    
    func test_player_returnsDisplayPlayer() async {

        let display = MockPlayer()
        let engine = VideoEngine(
            displayPlayer: display,
            preloadPlayer: MockPlayer()
        )

        let player = engine.player

        XCTAssertTrue(player === display)
    }
}

final class MockPlayer: PlayerProtocol {

    var currentItem: AVPlayerItem?

    var didPlay = false
    var didPause = false
    var didSeek = false
    var replacedItems: [AVPlayerItem?] = []

    func replaceCurrentItem(with item: AVPlayerItem?) {
        currentItem = item
        replacedItems.append(item)
    }

    func play() {
        didPlay = true
    }

    func pause() {
        didPause = true
    }

    func seek(to time: CMTime) {
        didSeek = true
    }

    func configureForFeed() {}
}

