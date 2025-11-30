public final class MapViewDIContainer {
    public static let shared = MapViewDIContainer()

    private init() {}

    // MARK: – Factory: Network
    private func makeNetworkClient() -> NetworkClientProtocol {
        NetworkClient()
    }

    private func makeLocationNetworkService() -> LocationNetworkServiceProtocol {
        LocationNetworkService(client: makeNetworkClient())
    }

    // MARK: – Factory: Repository
    func makeMapRepository() -> LocationRepositoryProtocol {
        LocationRepository(service: makeLocationNetworkService())
    }

    // MARK: – Factory: UseCase
    func makeSendLocationUseCase() -> SendLocationUseCaseProtocol {
        DefaultSendLocationUseCase(repo: makeMapRepository())
    }

    // MARK: – Factory: ViewModel
    func makeMapViewModel() -> MapViewModel {
        MapViewModel(sendLocationUseCase: makeSendLocationUseCase())
    }
}
