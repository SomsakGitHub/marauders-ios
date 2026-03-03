//import SwiftUI
//import AVKit
//
//struct PlayerView: View {
//    @State var player = AVPlayer()
//    let avPlayer = AVPlayer(url: Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!)
//    
//    var body: some View {
//        ZStack {
//            VideoPlayer(player: avPlayer)
//                .scaledToFill()
//                .ignoresSafeArea()
//                .onAppear {
//                    avPlayer.play()
//                    avPlayer.actionAtItemEnd = .none
//                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { (_) in
//                        avPlayer.seek(to: .zero)
//                        avPlayer.play()
//                    }
//            }
//        }
//    }
//}
//
//#Preview {
//    PlayerView()
//}

//import SwiftUI
//
//struct VTabView: View {
//    var body: some View {
//        TabView {
//            ZStack {
//                PlayerView()
//                HStack {
//                    Spacer()
////                    ReactionButtons1View()
//                }
//                .frame(width: UIScreen.main.bounds.width)
//            }
//
////            ZStack {
////                ThirdVideoView()
////                HStack {
////                    Spacer()
////                    ReactionButtons3View()
////                }
////                .frame(width: UIScreen.main.bounds.width)
////            }
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .ignoresSafeArea()
//    }
//}
//
//#Preview {
//    VTabView()
//}

