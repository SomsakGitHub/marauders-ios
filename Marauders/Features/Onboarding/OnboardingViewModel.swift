import SwiftUI
import Combine
import CoreLocation

@MainActor
final class OnboardingViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldOpenSettings = false

    private let requestLocationUseCase: RequestLocationUseCaseProtocol
    private let locationService: LocationServiceProtocol
    private let onFinish: () -> Void

    init(
        requestLocationUseCase: RequestLocationUseCaseProtocol,
        locationService: LocationServiceProtocol,
        onFinish: @escaping () -> Void
    ) {
        self.requestLocationUseCase = requestLocationUseCase
        self.locationService = locationService
        self.onFinish = onFinish
    }

    func requestLocation() {

        let status = locationService.authorizationStatus

        switch status {

        case .notDetermined:

            Task {

                do {

                    isLoading = true

                    try await requestLocationUseCase.execute()

                    onFinish()

                } catch {

                    if let error = error as? LocationError,
                       error == .permissionDenied {

                        errorMessage = "Location permission denied"

                    } else {

                        errorMessage = "Unable to fetch location"

                    }

                }

                isLoading = false
            }

        case .denied, .restricted:

            shouldOpenSettings = true

        case .authorizedAlways, .authorizedWhenInUse:

            onFinish()

        @unknown default:
            break
        }
    }
}
