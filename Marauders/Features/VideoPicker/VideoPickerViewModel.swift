//
//  VideoPickerViewModel.swift
//  Marauders
//
//  Created somsak on 25/3/2569 BE.
//

import Foundation
import Combine

@MainActor
final class VideoPickerViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let VideoPickeruseCase: VideoPickerUseCaseProtocol
    
    // MARK: - Init
    init(VideoPickeruseCase: VideoPickerUseCaseProtocol) {
        self.VideoPickeruseCase = VideoPickeruseCase
    }
}
