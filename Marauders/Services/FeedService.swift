import Foundation

protocol FeedServiceProtocol {
    func fetchPosts() async throws -> [Post]
}

class FeedService: FeedServiceProtocol {
    private let baseURL = " http://127.0.0.1:8080/health"
    
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Post].self, from: data)
    }
}


