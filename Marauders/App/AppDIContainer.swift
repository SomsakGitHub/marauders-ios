import SwiftUI

final class AppDIContainer {
    
    // Services

    lazy var locationService: LocationServiceProtocol = LocationService()

    // Managers

    lazy var appLaunchManager: AppLaunchManaging =
        AppLaunchManager(locationService: locationService)

    // UseCases

    lazy var requestLocationUseCase: RequestLocationUseCaseProtocol =
        RequestLocationUseCase(locationService: locationService)

    // Repositories

//    lazy var feedRepository = FeedRepository(apiClient: apiClient)

    // UseCases

//    lazy var fetchFeedUseCase = FetchFeedUseCase(repository: feedRepository)
}

extension AppDIContainer {

    func makeOnboardingView(onFinish: @escaping () -> Void) -> some View {

        let vm = OnboardingViewModel(
            requestLocationUseCase: requestLocationUseCase, locationService: locationService,
            onFinish: onFinish
        )

        return OnboardingView(viewModel: vm)
    }
    
    // MARK: – Factory: Network
    private func makeNetworkClient() -> NetworkClientProtocol {
        NetworkClient()
    }

    private func makeFeedNetworkService() -> FeedNetworkServiceProtocol {
        FeedNetworkService(client: makeNetworkClient())
    }
    
    // MARK: – Factory: Repository
    func makeFeedRepository() -> FeedRepositoryProtocol {
        FeedRepository(service: makeFeedNetworkService())
    }
    
    // MARK: – Factory: UseCase
    func makeFetchVideoUseCase() -> FetchVideoUseCaseProtocol {
        DefaultFetchVideoUseCase(repo: makeFeedRepository())
    }

    // MARK: – Factory: ViewModel
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(fetchVideoUseCase: makeFetchVideoUseCase())
    }

    func makeFeedView() -> some View {

        return FeedView(viewModel: makeFeedViewModel())
    }
    
    func makeLocationPermissionBlocker() -> some View {

//        let vm = FeedViewModel(fetchFeedUseCase: fetchFeedUseCase)

        return LocationPermissionBlocker()
    }
}
