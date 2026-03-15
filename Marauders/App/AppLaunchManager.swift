import CoreLocation

enum AppLaunchRoute: Equatable {
    case onboarding
    case feed
    case locationPermissionBlocker
}

protocol AppLaunchManaging {
    func decideInitialRoute() -> AppLaunchRoute

}

final class AppLaunchManager: AppLaunchManaging {

    private let locationService: LocationServiceProtocol

    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    func decideInitialRoute() -> AppLaunchRoute {

        let status = locationService.authorizationStatus

        switch status {

        case .authorizedAlways, .authorizedWhenInUse:
            return .feed
            
        case .denied, .restricted:
            return .locationPermissionBlocker

        default:
            return .onboarding
        }
    }
}
