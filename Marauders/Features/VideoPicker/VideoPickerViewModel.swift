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
    private let videoPickeruseCase: VideoPickerUseCaseProtocol
    
    @Published var isUploading = false
    @Published var uploadSuccess = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(useCase: VideoPickerUseCaseProtocol) {
        self.videoPickeruseCase = useCase
    }
    
    func uploadVideo(url: URL) {
        Task {
            do {
                isUploading = true
                try await videoPickeruseCase.execute(fileURL: url)
                uploadSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isUploading = false
        }
    }
}
