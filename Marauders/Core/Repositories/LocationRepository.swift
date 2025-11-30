protocol LocationRepositoryProtocol {
    func updateLocation(_ dto: LocationDTO) async throws
}

final class LocationRepository: LocationRepositoryProtocol {
    private let service: LocationNetworkServiceProtocol

    init(service: LocationNetworkServiceProtocol) {
        self.service = service
    }

    func updateLocation(_ dto: LocationDTO) async throws {
        try await service.sendLocation(dto)
    }
}
