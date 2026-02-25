//
//  FeedSceneView.swift
//  marauderS
//
//  Created by somsak on 30/4/2568 BE.
//

import SwiftUI
import AVFoundation
import Foundation
import CoreLocation
import Combine
import AVKit

struct FeedSceneView: View {
    
    @StateObject var viewModel = FeedViewModel()
    @State private var scrollPosition: String?
    @State private var player = AVPlayer()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.posts) { post in
                    FeedCellSceneView(post: post, player: player)
                        .id(post.id)
                        .onAppear { playInitialVideoIfNecessary() }
                }
            }
            .scrollTargetLayout()
        }
        .onAppear{
            player.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (_) in
                player.seek(to: .zero)
                player.play()
            }
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        .onChange(of: scrollPosition) { oldValue, newValue in
            print("DEBUG: Scroll position changed to: \(newValue)")
            playVideoOnChangeOfScrollPosition(postId: newValue)
        }
        .task {
//            await viewModel.fetchData()
        }
    }
    
    func playInitialVideoIfNecessary(){
        guard scrollPosition == nil, let post = viewModel.posts.first, player.currentItem == nil else { return }
        let item = AVPlayerItem(url: post.videoUrl)
        player.replaceCurrentItem(with: item)
    }
    
    func playVideoOnChangeOfScrollPosition(postId: String?){
        guard let currentPostId = viewModel.posts.first(where: { $0.id == postId}) else { return }
        
        player.replaceCurrentItem(with: nil)
        let playerItem = AVPlayerItem(url: currentPostId.videoUrl)
        player.replaceCurrentItem(with: playerItem)
//        player.play()
    }
}

#Preview {
    FeedSceneView()
}

class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
//    @Published var data: DataType?
    
    let videoUrls = [
        Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!,
        Bundle.main.url(forResource: "fireworks", withExtension: "mp4")!,
        Bundle.main.url(forResource: "selfie", withExtension: "mp4")!,
        Bundle.main.url(forResource: "threeDancing", withExtension: "mp4")!,
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
    ]
    
    init () {
        fetchPosts()
    }
    
    func fetchPosts() {
        self.posts = [
            .init(id: NSUUID().uuidString, videoUrl: videoUrls[0], latitude: 13.71646928950651, longitude: 100.52907189548483),
            .init(id: NSUUID().uuidString, videoUrl: videoUrls[1], latitude: 1.0, longitude: 100.0),
            .init(id: NSUUID().uuidString, videoUrl: videoUrls[2], latitude: 13.712090225574308, longitude: 100.53229446917453),
            .init(id: NSUUID().uuidString, videoUrl: videoUrls[3], latitude: 1.0, longitude: 1.0),
        ]
        
//        let latitude = AppSettings.shared.latitude
//        let longitude = AppSettings.shared.longitude
//        print("latitude", latitude)
//        print("longitude", longitude)
        
        let radiusInMeters = 1000.0 // 1 กิโลเมตร

//        self.posts = posts.filter { post in
//            let distance = distanceInMeters(
//                lat1: latitude,
//                lon1: longitude,
//                lat2: post.latitude,
//                lon2: post.longitude
//            )
//            return distance <= radiusInMeters
//        }
    }
    
    func distanceInMeters(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        return loc1.distance(from: loc2) // คืนค่าเป็นเมตร
    }
    
//    func fetchData() async {
//        do {
//            let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decodedData = try JSONDecoder().decode(DataType.self, from: data)
//            DispatchQueue.main.async {
//                self.data = decodedData
//            }
//        } catch {
//            print("Error fetching data: \(error)")
//        }
//    }
}

struct DataType: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.exitsFullScreenWhenPlaybackEnds = true
        controller.allowsPictureInPicturePlayback = true
        controller.videoGravity = .resizeAspectFill // makes video full screen
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

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

struct VTabView: View {
    var body: some View {
        TabView {
            ZStack {
                PlayerView()
                HStack {
                    Spacer()
//                    ReactionButtons1View()
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            
//            ZStack {
//                ThirdVideoView()
//                HStack {
//                    Spacer()
//                    ReactionButtons3View()
//                }
//                .frame(width: UIScreen.main.bounds.width)
//            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

#Preview {
    VTabView()
}

struct Post: Identifiable, Codable {
    let id: String
    let videoUrl: URL
    let latitude: Double
    let longitude: Double
}

struct FeedCellSceneView: View {
    let post: Post
    var player: AVPlayer
    
    init(post: Post, player: AVPlayer) {
        self.post = post
        self.player = player
    }
//    let av = AVPlayer(url: Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!)
    var body: some View {
        ZStack {
            CustomVideoPlayer(player: player)
//            VideoPlayer(player: av)
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
