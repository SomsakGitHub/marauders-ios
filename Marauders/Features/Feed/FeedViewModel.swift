//
//  FeedViewModel.swift
//  marauderS
//
//  Created by somsak on 5/5/2568 BE.
//

import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {

    @Published var videos: [VideoDTO] = []

//    private let repository: FeedRepositoryProtocol
    private let fetchVideoUseCase: FetchVideoUseCaseProtocol
    private var page = 0
    private var isLoading = false
    private let maxCache = 30
    
    private var currentPlayingID: String?
    private var playStartTime: Date?
    private var lastIndex: Int?

    init(fetchVideoUseCase: FetchVideoUseCaseProtocol) {
        self.fetchVideoUseCase = fetchVideoUseCase
        Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        page += 1
//        let newItems = try? await repository.fetch(page: page)
//        let newItems = try? await self.sendLocationUseCase.execute(dto: page)
        let newItems = try? await self.fetchVideoUseCase.execute(page: page)
        

        videos.append(contentsOf: newItems?.data ?? [])

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
