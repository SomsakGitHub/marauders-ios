//
//  VideoPickerUseCase.swift
//  Marauders
//
//  Created somsak on 25/3/2569 BE.
//

import Foundation

protocol VideoPickerUseCaseProtocol {
    func execute(fileURL: URL) async throws
}

final class DefaultVideoPickerUseCase: VideoPickerUseCaseProtocol {
    
    private let repo: VideoPickerRepositoryProtocol
    
    init(repo: VideoPickerRepositoryProtocol) {
        self.repo = repo
    }
    
    func execute(fileURL: URL) async throws {
        try await repo.uploadVideo(fileURL: fileURL)
    }
}

