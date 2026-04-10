import Foundation

protocol VideoPickerRepositoryProtocol {
    func uploadVideo(fileURL: URL) async throws
}

final class VideoPickerRepository: VideoPickerRepositoryProtocol {
    private let service: VideoPickerNetworkServiceProtocol

    init(service: VideoPickerNetworkServiceProtocol) {
        self.service = service
    }

    func uploadVideo(fileURL: URL) async throws {
        try await service.uploadVideo(fileURL: fileURL)
    }
}


final class DefaultVideoPickerRepository: VideoPickerRepositoryProtocol {
    
    func uploadVideo(fileURL: URL) async throws {
        
        var request = URLRequest(url: URL(string: "https://your-api.com/upload")!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let filename = fileURL.lastPathComponent
        let mimeType = "video/mp4"
        
        let fileData = try Data(contentsOf: fileURL)
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

