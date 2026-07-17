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
    private let likeVideoUseCase: LikeVideoUseCaseProtocol
    private let videoEngine: VideoEngineProtocol
    private let analytics: AnalyticsProtocol
    
    private var page = 0
    private var isLoading = false
    private let maxCache = 30
    
    private var currentPlayingID: String?
    private var playStartTime: Date?
    private var lastIndex: Int?
    
    private var nextCursor: String?
    private var hasMore = true

    init(
        fetchVideoUseCase: FetchVideoUseCaseProtocol,
        likeVideoUseCase: LikeVideoUseCaseProtocol,
        videoEngine: VideoEngineProtocol = VideoEngine.shared,
        analytics: AnalyticsProtocol = AnalyticsManager.shared
    ) {
        self.fetchVideoUseCase = fetchVideoUseCase
        self.likeVideoUseCase = likeVideoUseCase
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
        guard hasMore else { return }
        
        isLoading = true
        defer { isLoading = false }

        page += 1
        
        do {            
            let response = try await fetchVideoUseCase.execute(cursor: nextCursor)

            videos.append(contentsOf: response.videos)

            nextCursor = response.nextCursor
            hasMore = response.nextCursor != nil
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

    func toggleLike(for video: VideoDTO) {
        guard let index = videos.firstIndex(where: { $0.id == video.id }) else { return }

        let wasLiked = videos[index].isLiked
        let newLikeCount = wasLiked ? videos[index].likeCount - 1 : videos[index].likeCount + 1

        videos[index] = VideoDTO(
            id: video.id,
            userId: video.userId,
            status: video.status,
            originalObjectKey: video.originalObjectKey,
            playbackManifestUrl: video.playbackManifestUrl,
            durationMs: video.durationMs,
            width: video.width,
            height: video.height,
            thumbnailUrl: video.thumbnailUrl,
            createdAt: video.createdAt,
            updatedAt: video.updatedAt,
            user: video.user,
            likeCount: newLikeCount,
            isLiked: !wasLiked
        )

        Task {
            do {
                if wasLiked {
                    try await likeVideoUseCase.unlike(videoId: video.id)
                } else {
                    try await likeVideoUseCase.like(videoId: video.id)
                }
            } catch {
                videos[index] = video
            }
        }
    }
}
