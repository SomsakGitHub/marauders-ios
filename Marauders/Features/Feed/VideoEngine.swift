import Foundation
import UIKit
import AVFoundation
import Combine

protocol PlayerProtocol: AnyObject {
    func replaceCurrentItem(with item: AVPlayerItem?)
    func play()
    func pause()
    func seek(to time: CMTime)
    var currentItem: AVPlayerItem? { get }

    func configureForFeed()
}

extension AVPlayer: PlayerProtocol {

    func configureForFeed() {
        actionAtItemEnd = .none
        automaticallyWaitsToMinimizeStalling = false
    }
}

@MainActor
final class VideoEngine: ObservableObject {

    static let shared = VideoEngine()

    @Published private(set) var state: PlaybackState = .idle

    private let displayPlayer: PlayerProtocol
    private let preloadPlayer: PlayerProtocol

    init(
        displayPlayer: PlayerProtocol = AVPlayer(),
        preloadPlayer: PlayerProtocol = AVPlayer()
    ) {
        self.displayPlayer = displayPlayer
        self.preloadPlayer = preloadPlayer

        displayPlayer.configureForFeed()
        preloadPlayer.configureForFeed()

        observeAppLifecycle()
        observeMemoryPressure()
        observeLoop()
    }

    private var currentID: String?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    private func observeLoop() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.displayPlayer.seek(to: .zero)
                self.displayPlayer.play()
            }
        }
    }

    // MARK: - Public

    // Logic layer
    var player: PlayerProtocol {
        displayPlayer
    }

    // UI layer
    var renderPlayer: AVPlayer? {
        displayPlayer as? AVPlayer
    }

    func play(video: VideoDTO) {

        guard currentID != video.id else { return }

        state = .loading

        let item = AVPlayerItem(url: video.videoURL)
        item.preferredForwardBufferDuration = 5

        displayPlayer.replaceCurrentItem(with: item)
        displayPlayer.play()

        currentID = video.id
        state = .playing
    }

    func preload(video: VideoDTO?) {

        guard let video else { return }

        let item = AVPlayerItem(url: video.videoURL)
        item.preferredForwardBufferDuration = 3

        preloadPlayer.replaceCurrentItem(with: item)
    }

    func swapToPreloaded() {

        guard let nextItem = preloadPlayer.currentItem else { return }

        displayPlayer.replaceCurrentItem(with: nextItem)
        displayPlayer.play()
    }

    // MARK: - Lifecycle

    private func observeMemoryPressure() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.preloadPlayer.replaceCurrentItem(with: nil)
            }
        }
    }

    private func observeAppLifecycle() {

        NotificationCenter.default.publisher(
            for: UIApplication.willResignActiveNotification
        )
        .sink { [weak self] _ in
            self?.displayPlayer.pause()
        }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in
            self?.displayPlayer.play()
        }
        .store(in: &cancellables)
    }
}

