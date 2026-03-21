import Foundation

protocol NetworkClientProtocol {
    func send<T: Decodable>(_ request: APIRequest) async throws -> T
    func sendVoid(_ request: APIRequest) async throws
}

final class NetworkClient: NetworkClientProtocol {

    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
        let urlRequest = try buildRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // print raw data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response JSON:", jsonString)
        }

        try validate(response: response, data: data)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Decode error:", error)
            print(String(data: data, encoding: .utf8) ?? "")
            throw error
        }
    }

    func sendVoid(_ request: APIRequest) async throws {
        let urlRequest = try buildRequest(request)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        try validate(response: response, data: data)
    }
}

extension NetworkClient {
    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            // สามารถ decode server error message ได้
            throw APIError.httpError(code: http.statusCode, data: data)
        }
    }
}

enum APIError: Error {
    case invalidResponse
    case httpError(code: Int, data: Data?)
    case decodingError(Error)
    case underlying(Error)
    case unauthorized
    case cancelled
    case unknown
}


extension NetworkClient {
    private func buildRequest(_ request: APIRequest) throws -> URLRequest {
        let url = request.baseURL.appendingPathComponent(request.path)
        var req = URLRequest(url: url)

        req.httpMethod = request.method.rawValue
        req.allHTTPHeaderFields = request.headers
        req.httpBody = request.body

        return req
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct EmptyResponse: Decodable {}



