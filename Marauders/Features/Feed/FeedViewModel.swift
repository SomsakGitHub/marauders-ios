//
//  FeedViewModel.swift
//  marauderS
//
//  Created by somsak on 5/5/2568 BE.
//

import Foundation
import Combine
import AVFoundation

protocol VideoEngineProtocol {
    var state: PlaybackState { get }
    var player: PlayerProtocol { get }
    
    func play(video: VideoDTO)
    func preload(video: VideoDTO?)
}

protocol AnalyticsProtocol {
    func trackWatch(id: String, duration: Double)
    func flush()
}

extension VideoEngine: VideoEngineProtocol {}
extension AnalyticsManager: AnalyticsProtocol {}

@MainActor
final class FeedViewModel: ObservableObject {

    @Published var videos: [VideoDTO] = []

    private let fetchVideoUseCase: FetchVideoUseCaseProtocol
    private let videoEngine: VideoEngineProtocol
    private let analytics: AnalyticsProtocol
    
    private var page = 0
    private var isLoading = false
    private let maxCache = 30
    
    private var currentPlayingID: String?
    private var playStartTime: Date?
    private var lastIndex: Int?

    init(
        fetchVideoUseCase: FetchVideoUseCaseProtocol,
        videoEngine: VideoEngineProtocol = VideoEngine.shared,
        analytics: AnalyticsProtocol = AnalyticsManager.shared
    ) {
        self.fetchVideoUseCase = fetchVideoUseCase
        self.videoEngine = videoEngine
        self.analytics = analytics
        
        Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        page += 1
        
        do {
            let response = try await fetchVideoUseCase.execute()
            videos.append(contentsOf: response.data)
        } catch {
            print("❌ fetch video error:", error)
        }

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

        videoEngine.play(video: video)

        // Direction detection
        let direction = (lastIndex ?? 0) < index ? 1 : -1
        lastIndex = index

        if direction == 1 {
            videoEngine.preload(video: videos[safe: index + 1])
        } else {
            videoEngine.preload(video: videos[safe: index - 1])
        }

        if index >= videos.count - 3 {
            Task { await loadNextPage() }
        }
    }
}
