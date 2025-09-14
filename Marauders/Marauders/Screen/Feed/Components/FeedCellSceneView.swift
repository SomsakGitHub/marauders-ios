import SwiftUI
import AVKit

struct FeedCellSceneView: View {
    let post: Post
    var player: AVPlayer
    
    init(post: Post, player: AVPlayer) {
        self.post = post
        self.player = player
    }

    var body: some View {
        ZStack {
            CustomVideoPlayer(player: player)
                .containerRelativeFrame([.horizontal, .vertical])
        }
        .onTapGesture {
            switch player.timeControlStatus {
            case .paused:
                player.play()
            case .waitingToPlayAtSpecifiedRate:
                break
            case .playing:
                player.pause()
            @unknown default :
                break
            }
        }
    }
}

#Preview {
    let post = Post(id: "", videoUrl: URL(fileURLWithPath: ""), latitude: 100, longitude: 100)
    FeedCellSceneView(post: post, player: AVPlayer())
}
