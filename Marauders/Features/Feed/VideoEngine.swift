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

    private let player: AVQueuePlayer
    private var queueItems: [String: AVPlayerItem] = [:]

    init() {
        
        self.player = AVQueuePlayer()
        player.actionAtItemEnd = .advance

        observeAppLifecycle()
//        observeMemoryPressure()
        observeLoop()
        warmUp()
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
                self.player.seek(to: .zero)
                self.player.play()
            }
        }
    }
    
    private func warmUp() {
        let dummy = AVPlayerItem(url: URL(fileURLWithPath: "/dev/null"))
        player.replaceCurrentItem(with: dummy)
        player.pause()
        player.removeAllItems() // 👈 สำคัญ
    }

    // MARK: - Public

    // Logic layer
//    var player: PlayerProtocol {
//        displayPlayer
//    }

    // UI layer
    var renderPlayer: AVPlayer {
        player
    }

    func play(video: VideoDTO) {

        guard currentID != video.id else { return }

        player.removeAllItems() // reset queue

        queueItems.removeAll()

        let current = AVPlayerItem(url: video.videoURL)
        current.preferredForwardBufferDuration = 2

        player.insert(current, after: nil)

        currentID = video.id
        player.play()
    }

    func preload(video: VideoDTO?) {
        guard let video else { return }

        if queueItems[video.id] != nil { return }

        let item = AVPlayerItem(url: video.videoURL)
        item.preferredForwardBufferDuration = 2

        queueItems[video.id] = item

        // 👉 insert ต่อท้ายตัวสุดท้าย
        if let last = player.items().last {
            player.insert(item, after: last)
        } else {
            player.insert(item, after: nil)
        }

        trimQueueIfNeeded()
    }
    
    private func trimQueueIfNeeded() {
        let items = player.items()

        if items.count > 3 {
            player.remove(items.first!)
        }
    }
    
    func playNext(video: VideoDTO) {

        guard currentID != video.id else { return }

        currentID = video.id

        if let next = player.items().dropFirst().first,
           let asset = next.asset as? AVURLAsset,
           asset.url == video.videoURL {

            player.advanceToNextItem()

        } else {
            // fallback
            player.removeAllItems()

            let item = AVPlayerItem(url: video.videoURL)
            player.insert(item, after: nil)
        }

        player.play()
    }

    private func observeAppLifecycle() {

        NotificationCenter.default.publisher(
            for: UIApplication.willResignActiveNotification
        )
        .sink { [weak self] _ in
            self?.player.pause()
        }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in
            self?.player.play()
        }
        .store(in: &cancellables)
    }
}

