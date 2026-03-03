
import AVFoundation
import SwiftUI
import Combine

enum PlaybackState {
    case idle
    case loading
    case playing
    case paused
    case stalled
}

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

//struct FeedView: View {
//
//    @StateObject private var viewModel = FeedViewModel()
//    @State private var currentID: String?
//
//    var body: some View {
//        ScrollView(.vertical) {
//            LazyVStack(spacing: 0) {
//                ForEach(viewModel.videos) { video in
//                    VideoCell(video: video)
//                        .containerRelativeFrame(.vertical)
//                        .id(video.id)
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .scrollTargetBehavior(.paging)
//        .scrollPosition(id: $currentID)
//        .ignoresSafeArea()
//        .onChange(of: currentID) { id in
//            guard let id else { return }
//            viewModel.didFocusVideo(id: id)
//        }
//        .task {
//            await viewModel.loadNextPage()
//        }
//    }
//}

struct FeedView: View {

    @StateObject private var viewModel = FeedViewModel()
    @State private var currentID: String?

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.videos) { video in
                    VideoCell(video: video)
                        .containerRelativeFrame(.vertical)
                        .id(video.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentID)
        .ignoresSafeArea()

        // 👇 สำคัญมาก
        .onChange(of: viewModel.videos) { videos in
            if currentID == nil {
                currentID = videos.first?.id
            }
        }

        .onChange(of: currentID) { id in
            guard let id else { return }
            viewModel.didFocusVideo(id: id)
        }

        .task {
            await viewModel.loadNextPage()
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
    
    private var currentPlayingID: String?
    private var playStartTime: Date?
    private var lastIndex: Int?

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

        guard currentPlayingID != id else { return }
        currentPlayingID = id

        guard let index = videos.firstIndex(where: { $0.id == id }) else { return }

        let video = videos[index]

        VideoEngine.shared.play(video: video)

        // Direction detection
        let direction = (lastIndex ?? 0) < index ? 1 : -1
        lastIndex = index

        if direction == 1 {
            VideoEngine.shared.preload(video: videos[safe: index + 1])
        } else {
            VideoEngine.shared.preload(video: videos[safe: index - 1])
        }

        if index >= videos.count - 3 {
            Task { await loadNextPage() }
        }
    }
}

struct VideoCell: View {

    let video: VideoItem

    var body: some View {
        ZStack {
            PlayerLayerView()
        }
        .ignoresSafeArea()
    }
}

struct PlayerLayerView: UIViewRepresentable {

    func makeUIView(context: Context) -> PlayerContainerView {
        PlayerContainerView(player: VideoEngine.shared.playerForDisplay())
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {

    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class AnalyticsManager {

    static let shared = AnalyticsManager()

    private var buffer: [(id: String, duration: Double)] = []

    func trackWatch(id: String, duration: Double) {
        buffer.append((id, duration))

        if buffer.count >= 5 {
            flush()
        }
    }

    func flush() {
        guard !buffer.isEmpty else { return }

        print("Sending batch:", buffer)

        // send to backend here

        buffer.removeAll()
    }
}

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
