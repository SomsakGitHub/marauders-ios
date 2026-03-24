import SwiftUI
import CoreLocation

struct AppCoordinator: View {

    @State private var route: AppLaunchRoute
    @Environment(\.scenePhase) private var scenePhase

    let container: AppDIContainer

    init(container: AppDIContainer) {

        self.container = container

        let initial = container.appLaunchManager.decideInitialRoute()

        _route = State(initialValue: initial)
    }

    var body: some View {

        Group {

            switch route {

            case .onboarding:

                container.makeOnboardingView {
                    route = .feed
                }

            case .feed:

                container.makeFeedView()

            case .locationPermissionBlocker:

                container.makeLocationPermissionBlocker()
                
            case .videoPicker:

                container.videoPickerView()
                
            case .profile:

                container.profileView()
            }

        }
        .onChange(of: scenePhase) {_, phase in

            guard phase == .active else { return }

            recheckPermission()
        }
    }

    private func recheckPermission() {

        let newRoute = container.appLaunchManager.decideInitialRoute()

        if newRoute != route {
            route = newRoute
        }
    }
}
