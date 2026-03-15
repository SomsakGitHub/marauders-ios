import MapKit

protocol RequestLocationUseCaseProtocol {
    func execute() async throws
}

final class RequestLocationUseCase: RequestLocationUseCaseProtocol {

    private let locationService: LocationServiceProtocol

    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    func execute() async throws {
        _ = try await locationService.requestPermission()
    }
}
