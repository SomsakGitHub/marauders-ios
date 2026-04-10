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
