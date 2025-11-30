import Foundation

protocol NetworkClientProtocol {
    func send<T: Decodable>(_ request: APIRequest) async throws -> T
    func sendVoid(_ request: APIRequest) async throws
}

final class NetworkClient: NetworkClientProtocol {

    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
        let urlRequest = try buildRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        try validate(response: response, data: data)

        return try JSONDecoder().decode(T.self, from: data)
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

//import Foundation
//
//protocol APIServiceProtocol {
//    func request<T: Decodable>(
//        endpoint: String,
//        method: String,
//        completion: @escaping (Result<T, Error>) -> Void
//    )
//}
//
//final class APIService: APIServiceProtocol {
//    func request<T: Decodable>(
//        endpoint: String,
//        method: String = "GET",
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard let url = URL(string: endpoint) else { return }
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            if let data = data {
//                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
//                   let jsonString = String(data: prettyData, encoding: .utf8) {
//                    print("Pretty JSON:\n\(jsonString)")
//                }
//                
//                do {
//                    let decoded = try JSONDecoder().decode(T.self, from: data)
//                    completion(.success(decoded))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
//}



