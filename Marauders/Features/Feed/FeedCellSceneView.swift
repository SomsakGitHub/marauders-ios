////
////  FeedCellSceneView.swift
////  marauderS
////
////  Created by somsak on 5/5/2568 BE.
////
//
//import SwiftUI
//import AVKit
//
//struct FeedCellSceneView: View {
//    let post: Post
//    var player: AVPlayer
//    
//    init(post: Post, player: AVPlayer) {
//        self.post = post
//        self.player = player
//    }
////    let av = AVPlayer(url: Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!)
//    var body: some View {
//        ZStack {
//            CustomVideoPlayer(player: player)
////            VideoPlayer(player: av)
//                .containerRelativeFrame([.horizontal, .vertical])
//        }
//        .onTapGesture {
//            switch player.timeControlStatus {
//            case .paused:
//                player.play()
//            case .waitingToPlayAtSpecifiedRate:
//                break
//            case .playing:
//                player.pause()
//            @unknown default :
//                break
//            }
//        }
//    }
//}
//
//#Preview {
//    let post = Post(id: "", videoUrl: URL(fileURLWithPath: ""), latitude: 100, longitude: 100)
//    FeedCellSceneView(post: post, player: AVPlayer())
//}
