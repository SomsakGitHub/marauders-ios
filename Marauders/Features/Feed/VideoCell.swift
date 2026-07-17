//
//  FeedCellSceneView.swift
//  marauderS
//
//  Created by somsak on 5/5/2568 BE.
//

import SwiftUI
import AVFoundation

protocol AVPlayerProvider {
    var avPlayer: AVPlayer { get }
}

extension AVPlayer: AVPlayerProvider {
    var avPlayer: AVPlayer { self }
}

struct VideoCell: View {

    let video: VideoDTO
    let isActive: Bool
    var onToggleLike: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PlayerLayerView(isActive: isActive)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Button {
                    onToggleLike?()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: video.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 28))
                            .foregroundStyle(video.isLiked ? .red : .white)
                            .shadow(color: .black.opacity(0.3), radius: 4)

                        Text("\(video.likeCount)")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                }
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100)
        }
    }
}

struct PlayerLayerView: UIViewRepresentable {
    
    let isActive: Bool

    func makeUIView(context: Context) -> PlayerContainerView {
        let player = VideoEngine.shared.renderPlayer
        return PlayerContainerView(player: player)
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        if isActive {
            uiView.play()
        } else {
            uiView.pause()
        }
    }
}

final class PlayerContainerView: UIView {

    private let playerLayer = AVPlayerLayer()
    private let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
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

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}
