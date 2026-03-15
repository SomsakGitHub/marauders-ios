import MapKit

protocol FetchUseCaseProtocol {
//    func fetchVideo(from location: CLLocation?) -> MKCoordinateRegion
}

struct FetchUseCase: FetchUseCaseProtocol {
//    func fetchVideo(from location: CLLocation?) -> MKCoordinateRegion {
//        guard let location = location else {
//            return MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: 13.63164, longitude: 13.63164),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            )
//        }
//
//        return MKCoordinateRegion(
//            center: location.coordinate,
//            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
//        )
//    }
}

protocol FetchVideoUseCaseProtocol {
    func execute(page: Int) async throws -> FeedResponse
}

final class DefaultFetchVideoUseCase: FetchVideoUseCaseProtocol {
    private let repo: FeedRepositoryProtocol

    init(repo: FeedRepositoryProtocol) {
        self.repo = repo
    }

    func execute(page: Int) async throws -> FeedResponse {
        try await repo.fetchVideo(page: 1)
    }
}
//
//final class MockMapUseCase: MapUseCaseProtocol {
//    var lastInput: CLLocation?
//    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion {
//        lastInput = location
//        return MKCoordinateRegion(
//            center: location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
//            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        )
//    }
//}
