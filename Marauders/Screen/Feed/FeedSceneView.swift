import SwiftUI
import AVFoundation

struct FeedSceneView: View {
    
    @StateObject private var viewModel: FeedViewModel
    @State private var scrollPosition: String?
    @State private var player = AVPlayer()
    
    init(services: ServiceContainer) {
        _viewModel = StateObject(
            wrappedValue: FeedViewModel(service: services.feed)
        )
    }
    
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
            print("DEBUG: Scroll position changed to: \(String(describing: newValue))")
            playVideoOnChangeOfScrollPosition(postId: newValue)
        }
        .task {
            await viewModel.fetchData()
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
    }
}

#Preview {
    FeedSceneView(services: ServiceContainer())
}
