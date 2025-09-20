import Foundation

protocol APIServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

final class APIService: APIServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                   let jsonString = String(data: prettyData, encoding: .utf8) {
                    print("Pretty JSON:\n\(jsonString)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
