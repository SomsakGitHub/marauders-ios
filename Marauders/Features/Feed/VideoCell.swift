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

    var body: some View {
        ZStack {
            PlayerLayerView()
        }
        .ignoresSafeArea()
    }
}

struct PlayerLayerView: UIViewRepresentable {

    func makeUIView(context: Context) -> PlayerContainerView {
        guard let player = VideoEngine.shared.renderPlayer else {
            fatalError("AVPlayer not available")
        }
        return PlayerContainerView(player: player)
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {

    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)

        playerLayer.player = player   // 👈 ตรง ๆ เลย
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
