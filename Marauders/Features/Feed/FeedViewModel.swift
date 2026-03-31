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
    var renderPlayer: AVPlayer { get }

    func play(video: VideoDTO)
    func playNext(video: VideoDTO)
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
        
        Task {
            await loadNextPage()

            if let first = videos.first {
                videoEngine.preload(video: first)
            }
        }
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

        guard let index = videos.firstIndex(where: { $0.id == id }) else { return }

        let video = videos[index]

        if currentPlayingID == nil {
            videoEngine.play(video: video) // first
        } else {
            videoEngine.playNext(video: video) // 👈 smooth scroll
        }

        currentPlayingID = id

        // preload ล่วงหน้า 2 ตัว
        videoEngine.preload(video: videos[safe: index + 1])
        videoEngine.preload(video: videos[safe: index + 2])
    }
}
