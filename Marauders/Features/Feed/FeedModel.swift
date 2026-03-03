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
