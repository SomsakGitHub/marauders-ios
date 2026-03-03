import Foundation
import UIKit
import AVFoundation
import Combine

final class VideoEngine: ObservableObject {

    static let shared = VideoEngine()

    @Published private(set) var state: PlaybackState = .idle

    private let displayPlayer = AVPlayer()
    private let preloadPlayer = AVPlayer()

    private var currentID: String?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        configure(displayPlayer)
        configure(preloadPlayer)
        observeAppLifecycle()
        observeMemoryPressure()
        observeLoop()
//        displayPlayer.automaticallyWaitsToMinimizeStalling = true
//        displayPlayer.preferredPeakBitRate = 0
    }

    // MARK: - Setup

    private func configure(_ player: AVPlayer) {
        player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false
    }

    private func observeLoop() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.displayPlayer.seek(to: .zero)
            self?.displayPlayer.play()
        }
    }

    // MARK: - Public

    func playerForDisplay() -> AVPlayer {
        displayPlayer
    }

    func play(video: VideoItem) {

        guard currentID != video.id else { return }

        state = .loading

        let item = AVPlayerItem(url: video.url)
        item.preferredForwardBufferDuration = 5

        displayPlayer.replaceCurrentItem(with: item)
        displayPlayer.play()

        currentID = video.id
        state = .playing
    }

    func preload(video: VideoItem?) {

        guard let video else { return }

        let item = AVPlayerItem(url: video.url)
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
            self?.preloadPlayer.replaceCurrentItem(with: nil)
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

