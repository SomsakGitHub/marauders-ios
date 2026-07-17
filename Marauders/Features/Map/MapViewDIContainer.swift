public final class MapViewDIContainer {
    public static let shared = MapViewDIContainer()

    private init() {}

    // MARK: – Factory: Network
    private func makeNetworkClient() -> NetworkClientProtocol {
        RetryNetworkClient(delegate: NetworkClient(), maxRetries: 3, baseDelay: 1.0)
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
    
    private func makeVideoRepository() -> VideoRepositoryProtocol {
        MockVideoRepository()
    }
    
    private func makePopularVideosUseCase() -> GetPopularVideosUseCaseProtocol {
        GetPopularVideosUseCase(
            repository: makeVideoRepository()
        )
    }

    // MARK: – Factory: ViewModel
    func makeMapViewModel() -> MapViewModel {
        MapViewModel(
            sendLocationUseCase: makeSendLocationUseCase(),
            popularVideosUseCase: makePopularVideosUseCase()
        )
    }
}
