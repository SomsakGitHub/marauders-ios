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
    let videos: [VideoDTO]
    let nextCursor: String?
}

struct VideoDTO: Decodable, Identifiable, Equatable {

    let id: String
    let userId: String
    let status: String

    let originalObjectKey: String
    let playbackManifestUrl: URL

    let durationMs: Int
    let width: Int
    let height: Int

    let thumbnailUrl: URL

    let createdAt: String
    let updatedAt: String

    let user: UserDTO

    let likeCount: Int
}

struct UserDTO: Decodable, Equatable {

    let id: String
    let username: String
    let displayName: String
    let avatarUrl: URL?
}
