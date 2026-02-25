import SwiftUI
import AVKit

struct PlayerView: View {
    @State var player = AVPlayer()
    let avPlayer = AVPlayer(url: Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!)
    
    var body: some View {
        ZStack {
            VideoPlayer(player: avPlayer)
                .scaledToFill()
                .ignoresSafeArea()
                .onAppear {
                    avPlayer.play()
                    avPlayer.actionAtItemEnd = .none
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { (_) in
                        avPlayer.seek(to: .zero)
                        avPlayer.play()
                    }
            }
        }
    }
}

#Preview {
    PlayerView()
}
