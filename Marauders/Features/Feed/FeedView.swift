//
//  FeedView.swift
//  marauderS
//
//  Created by somsak on 30/4/2568 BE.
//

import SwiftUI

struct FeedView: View {

    @StateObject private var viewModel: FeedViewModel
    @State private var currentID: String?
    let selectedTab: Int
    
    public init(viewModel: FeedViewModel, selectedTab: Int) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.selectedTab = selectedTab
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.videos) { video in
                    VideoCell(video: video, isActive: selectedTab == 0)
                        .containerRelativeFrame(.vertical)
                        .id(video.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentID)
        .ignoresSafeArea()

        // 👇 สำคัญมาก
        .onChange(of: viewModel.videos) { _, videos in
            if currentID == nil {
                currentID = videos.first?.id
            }
        }

        .onChange(of: currentID) { _, id in
            guard let id else { return }
            viewModel.didFocusVideo(id: id)
        }

        .task {
            await viewModel.loadNextPage()
        }
        
        .onAppear {
            if let first = viewModel.videos.first {
                currentID = first.id
                viewModel.didFocusVideo(id: first.id)
            }
        }
    }
}

final class AnalyticsManager {

    static let shared = AnalyticsManager()

    private var buffer: [(id: String, duration: Double)] = []

    func trackWatch(id: String, duration: Double) {
        buffer.append((id, duration))

        if buffer.count >= 5 {
            flush()
        }
    }

    func flush() {
        guard !buffer.isEmpty else { return }

        print("Sending batch:", buffer)

        // send to backend here

        buffer.removeAll()
    }
}
