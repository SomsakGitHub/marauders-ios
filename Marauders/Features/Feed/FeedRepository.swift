import Foundation

protocol FeedRepositoryProtocol {
    func fetch(page: Int) async throws -> [VideoItem]
}

final class FeedRepository: FeedRepositoryProtocol {

    func fetch(page: Int) async throws -> [VideoItem] {

        try await Task.sleep(nanoseconds: 800_000_000)

        let resources = [
            "oneDancing",
            "fireworks",
            "selfie",
            "threeDancing"
        ]

        return (0..<5).flatMap { _ in
            resources.compactMap { name in
                guard let url = Bundle.main.url(forResource: name, withExtension: "mp4") else {
                    return nil
                }
                return VideoItem(url: url)
            }
        }
    }
}
