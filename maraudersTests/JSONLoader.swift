@testable import Marauders
import Foundation

enum JSONLoader {

    static func load<T: Decodable>(_ filename: String) throws -> T {

        let bundle = Bundle(for: BundleMarker.self)

        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("❌ Missing JSON file: \(filename).json")
        }

        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(T.self, from: data)
    }
}

private final class BundleMarker {}

@MainActor
enum TestData {
    static let feedResponse: FeedResponse = {
        do {
            return try JSONLoader.load("FeedResponse")
        } catch {
            fatalError("❌ Failed to load FeedResponse.json: \(error)")
        }
    }()
}
