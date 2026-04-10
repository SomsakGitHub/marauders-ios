import Foundation

protocol VideoPickerNetworkServiceProtocol {
    func uploadVideo(fileURL: URL) async throws -> VideoPickerResponse
}

final class VideoPickerNetworkService: VideoPickerNetworkServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func uploadVideo(fileURL: URL) async throws -> VideoPickerResponse {
        try await client.send(LocationAPI.fetchVideo)
    }
}
