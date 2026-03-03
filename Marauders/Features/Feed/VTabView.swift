import Foundation

struct VideoItem: Identifiable {
    let id = UUID().uuidString
    let url: URL
}

import AVFoundation
import Combine

class VideoFeedViewModel: ObservableObject {

    @Published var videos: [VideoItem] = [
        VideoItem(url: Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!),
        VideoItem(url: Bundle.main.url(forResource: "fireworks", withExtension: "mp4")!),
        VideoItem(url: Bundle.main.url(forResource: "selfie", withExtension: "mp4")!),
        VideoItem(url: Bundle.main.url(forResource: "threeDancing", withExtension: "mp4")!)
    ]

    private var players: [String: AVPlayer] = [:]

    func player(for item: VideoItem) -> AVPlayer {
        if let player = players[item.id] {
            return player
        }

        let player = AVPlayer(url: item.url)
        player.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        players[item.id] = player
        return player
    }

    func pauseAll() {
        players.values.forEach { $0.pause() }
    }
}

import SwiftUI
import AVKit

struct VideoCellView: View {

    let player: AVPlayer

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
    }
}

struct FeedView: View {

    @StateObject private var viewModel = VideoFeedViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.videos) { video in
                    VideoCellView(player: viewModel.player(for: video))
                        .containerRelativeFrame(.vertical)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
    }
}
