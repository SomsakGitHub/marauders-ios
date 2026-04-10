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
    
    private func makeVideoPickerNetworkService() -> VideoPickerNetworkServiceProtocol {
        VideoPickerNetworkService(client: makeNetworkClient())
    }
    
    // MARK: – Factory: Repository
    func makeFeedRepository() -> FeedRepositoryProtocol {
        FeedRepository(service: makeFeedNetworkService())
    }
    
    func makeVideoPickerRepository() -> VideoPickerRepositoryProtocol {
        VideoPickerRepository(service: makeVideoPickerNetworkService())
    }
    
    // MARK: – Factory: UseCase
    func makeFetchVideoUseCase() -> FetchVideoUseCaseProtocol {
        DefaultFetchVideoUseCase(repo: makeFeedRepository())
    }
    
    func makeVideoPickerUseCase() -> VideoPickerUseCaseProtocol {
        DefaultVideoPickerUseCase(repo: makeVideoPickerRepository())
    }

    // MARK: – Factory: ViewModel
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(fetchVideoUseCase: makeFetchVideoUseCase())
    }
    
    func makeVideoPickerViewModel() -> VideoPickerViewModel {
        VideoPickerViewModel(useCase: makeVideoPickerUseCase())
    }
    
//    func makeMapViewModel() -> MapViewModel {
//        MapViewModel(fetchVideoUseCase: makeFetchVideoUseCase())
//    }

    func makeFeedView(selectedTab: Int ) -> some View {

        return FeedView(viewModel: makeFeedViewModel(), selectedTab: selectedTab)
    }
    
    func mapView() -> some View {
        
        return MapView(viewModel: MapViewDIContainer.shared.makeMapViewModel())
    }
    
    func makeLocationPermissionBlocker() -> some View {

//        let vm = FeedViewModel(fetchFeedUseCase: fetchFeedUseCase)

        return LocationPermissionBlocker()
    }
    
    func videoPickerView() -> some View {

        return VideoPickerView(viewModel: makeVideoPickerViewModel())
    }
    
    func profileView() -> some View {

        return MarauderMapView()
//        return ProfileView(viewModel: MockProfileViewModel())
    }
}
