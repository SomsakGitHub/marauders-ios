import Foundation
import AVFoundation
import SwiftUI
import Combine

struct VideoItem: Identifiable, Equatable {
    let id = UUID().uuidString
    let url: URL
}

protocol FeedRepositoryProtocol {
    func fetch(page: Int) async throws -> [VideoItem]
}

final class MockFeedRepository: FeedRepositoryProtocol {

    func fetch(page: Int) async throws -> [VideoItem] {

        try await Task.sleep(nanoseconds: 800_000_000)

        return (0..<5).map { _ in
            VideoItem(url: Bundle.main.url(
                forResource: "oneDancing",
                withExtension: "mp4")!)
        }
    }
}

struct FeedView: View {

    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.videos) { video in
                    VideoCell(
                        video: video,
                        onVisible: { id in
                            viewModel.didFocusVideo(id: id)
                        }
                    )
                    .containerRelativeFrame(.vertical)
                    .id(video.id)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        .onChange(of: viewModel.videos) { videos in
            if let first = videos.first {
                viewModel.didFocusVideo(id: first.id)
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )) { _ in
            if let id = viewModel.videos.first?.id {
                viewModel.didFocusVideo(id: id)
            }
        }
    }
}

@MainActor
final class FeedViewModel: ObservableObject {

    @Published var videos: [VideoItem] = []

    private let repository: FeedRepositoryProtocol
    private var page = 0
    private var isLoading = false
    private let maxCache = 30

    init(repository: FeedRepositoryProtocol = MockFeedRepository()) {
        self.repository = repository
        Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        page += 1
        let newItems = try? await repository.fetch(page: page)

        videos.append(contentsOf: newItems ?? [])

        // Memory limit
        if videos.count > maxCache {
            videos.removeFirst(videos.count - maxCache)
        }
    }

    func didFocusVideo(id: String) {
        guard let index = videos.firstIndex(where: { $0.id == id }) else { return }

        VideoPlaybackController.shared.play(video: videos[index])

        // preload next
        VideoPlaybackController.shared.preloadNext(
            video: videos[safe: index + 1]
        )

        if index >= videos.count - 3 {
            Task { await loadNextPage() }
        }
    }
}

struct VideoCell: View {

    let video: VideoItem
    let onVisible: (String) -> Void

    @State private var hasTriggered = false

    var body: some View {
        ZStack {
            PlayerLayerView()
        }
        .ignoresSafeArea()
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .global)) { frame in
                        let screenHeight = UIScreen.main.bounds.height

                        let visibleHeight = max(0,
                            min(frame.maxY, screenHeight) -
                            max(frame.minY, 0)
                        )

                        let percent = visibleHeight / screenHeight

                        if percent > 0.7 {
                            if !hasTriggered {
                                hasTriggered = true
                                onVisible(video.id)
                            }
                        } else {
                            hasTriggered = false
                        }
                    }
            }
        )
    }
}

struct PlayerLayerView: UIViewRepresentable {

    func makeUIView(context: Context) -> PlayerContainerView {
        PlayerContainerView()
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {

    private let playerLayer = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        playerLayer.player = VideoPlaybackController.shared.player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

@MainActor
final class VideoPlaybackController: ObservableObject {
    

    static let shared = VideoPlaybackController()
    private var preloadedItem: AVPlayerItem?
    private var playStartDate: Date?

    let player = AVPlayer()
    @Published var currentVideoID: String?
    @Published var isMuted: Bool = true

    private init() {
        player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(video: VideoItem) {
        guard currentVideoID != video.id else { return }

        // 🔥 Watch time log ตัวก่อนหน้า
        if let currentVideoID {
            logWatchTime(for: currentVideoID)
        }

        let item: AVPlayerItem

        if let preloadedItem {
            item = preloadedItem
            self.preloadedItem = nil
        } else {
            item = AVPlayerItem(url: video.url)
        }

        item.preferredForwardBufferDuration = 5

        player.replaceCurrentItem(with: item)
        player.isMuted = isMuted
        player.play()

        playStartDate = Date()
        currentVideoID = video.id
    }

    func stop() {
        if let currentVideoID {
            logWatchTime(for: currentVideoID)
        }
        player.pause()
    }

    func toggleMute() {
        isMuted.toggle()
        player.isMuted = isMuted
    }
    
    func preloadNext(video: VideoItem?) {
        guard let video else { return }

        let item = AVPlayerItem(url: video.url)
        item.preferredForwardBufferDuration = 5

        // trigger loading
        item.asset.loadValuesAsynchronously(forKeys: ["playable"])

        preloadedItem = item
    }
    
    private func logWatchTime(for id: String) {
        guard playStartDate != nil else { return }

        let duration = player.currentTime().seconds

        print("Video \(id) watched \(duration) sec")

        // 🔥 ตรงนี้ส่ง backend analytics
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
