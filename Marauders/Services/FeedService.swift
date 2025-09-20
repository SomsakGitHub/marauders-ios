import Foundation

protocol FeedServiceProtocol {
    func fetchPosts() async throws -> [Post]
}

class FeedService: FeedServiceProtocol {
    private let baseURL = "http://127.0.0.1:8080"
    
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let jsonString = String(data: prettyData, encoding: .utf8) {
            print("Pretty JSON:\n\(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Post].self, from: data)
    }
}


