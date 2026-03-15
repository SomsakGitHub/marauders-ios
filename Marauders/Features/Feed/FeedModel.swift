//
//  FeedModel.swift
//  marauderS
//
//  Created by somsak on 5/5/2568 BE.
//

import Foundation

enum PlaybackState {
    case idle
    case loading
    case playing
    case paused
    case stalled
}

struct VideoItem: Identifiable, Equatable {
    let id = UUID().uuidString
    let url: URL
}

struct FeedResponse: Decodable {
    let data: [VideoDTO]
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrev: Bool
}

struct VideoDTO: Decodable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let videoURL: URL
    let thumbnailURL: String
    let durationSeconds: Int
}
