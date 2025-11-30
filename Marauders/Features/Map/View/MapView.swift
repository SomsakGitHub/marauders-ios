import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    
    public init(viewModel: MapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            switch viewModel.status {
            case .authorizedAlways, .authorizedWhenInUse:
                mapContent

            case .notDetermined:
                if viewModel.showOnboarding {
                    LocationOnboardingView {
                        viewModel.requestPermission()
                    }
                    .transition(.opacity)
                }

            case .denied, .restricted:
                LocationPermissionBlocker {
                    viewModel.requestPermission()
                }

            default:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: viewModel.status)
    }

    private var mapContent: some View {
        CustomMap(
            region: $viewModel.region,
            onTap: viewModel.onUserTap,
            onMapReady: viewModel.onMapReady
        )
        .overlay {
            if !viewModel.isMapReady {
                ProgressView("Loading Map...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .transition(.opacity)
            }
        }
    }
}
