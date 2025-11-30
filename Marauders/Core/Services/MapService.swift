protocol LocationNetworkServiceProtocol {
    func sendLocation(_ dto: LocationDTO) async throws
}

final class LocationNetworkService: LocationNetworkServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func sendLocation(_ dto: LocationDTO) async throws {
        try await client.sendVoid(LocationAPI.updateLocation(dto))
    }
}

//final class MapService {
//    private let api: APIServiceProtocol
//
//    init(api: APIServiceProtocol) {
//        self.api = api
//    }
//
//    func saveCoordinate(coord: Coordinate, completion: @escaping (Result<[Coordinate], Error>) -> Void) {
//        api.request(endpoint: "http://127.0.0.1:8080/health",
//                    method: "GET",
//                    completion: completion)
//    }
//}
//
//
