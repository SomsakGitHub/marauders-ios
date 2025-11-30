import MapKit

protocol MapUseCaseProtocol {
    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion
}

struct MapUseCase: MapUseCaseProtocol {
    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion {
        guard let location = location else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 13.63164, longitude: 13.63164),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }

        return MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
    }
}

protocol SendLocationUseCaseProtocol {
    func execute(dto: LocationDTO) async throws
}

final class DefaultSendLocationUseCase: SendLocationUseCaseProtocol {
    private let repo: LocationRepositoryProtocol

    init(repo: LocationRepositoryProtocol) {
        self.repo = repo
    }

    func execute(dto: LocationDTO) async throws {
        try await repo.updateLocation(dto)
    }
}

final class MockMapUseCase: MapUseCaseProtocol {
    var lastInput: CLLocation?
    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion {
        lastInput = location
        return MKCoordinateRegion(
            center: location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
