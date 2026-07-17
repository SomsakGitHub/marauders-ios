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
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id, userId, status, originalObjectKey, playbackManifestUrl
        case durationMs, width, height, thumbnailUrl
        case createdAt, updatedAt, user, likeCount
    }

    init(
        id: String,
        userId: String,
        status: String,
        originalObjectKey: String,
        playbackManifestUrl: URL,
        durationMs: Int,
        width: Int,
        height: Int,
        thumbnailUrl: URL,
        createdAt: String,
        updatedAt: String,
        user: UserDTO,
        likeCount: Int,
        isLiked: Bool
    ) {
        self.id = id
        self.userId = userId
        self.status = status
        self.originalObjectKey = originalObjectKey
        self.playbackManifestUrl = playbackManifestUrl
        self.durationMs = durationMs
        self.width = width
        self.height = height
        self.thumbnailUrl = thumbnailUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.user = user
        self.likeCount = likeCount
        self.isLiked = isLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        status = try container.decode(String.self, forKey: .status)
        originalObjectKey = try container.decode(String.self, forKey: .originalObjectKey)
        playbackManifestUrl = try container.decode(URL.self, forKey: .playbackManifestUrl)
        durationMs = try container.decode(Int.self, forKey: .durationMs)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        thumbnailUrl = try container.decode(URL.self, forKey: .thumbnailUrl)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        user = try container.decode(UserDTO.self, forKey: .user)
        likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        isLiked = false
    }
}

struct UserDTO: Decodable, Equatable {

    let id: String
    let username: String
    let displayName: String
    let avatarUrl: URL?
}
