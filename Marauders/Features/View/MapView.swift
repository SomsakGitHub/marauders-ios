import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var vm = MapViewModel()

    var body: some View {
        ZStack {
            if vm.status == .authorizedAlways || vm.status == .authorizedWhenInUse {

                CustomMap(
                    region: $vm.region,
                    onTap: vm.onUserTap,
                    onMapReady: vm.onMapReady
                )
                .overlay {
                    if !vm.isMapReady {
                        ProgressView("Loading Map...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }

            } else if vm.status == .notDetermined && vm.showOnboarding {

                LocationOnboardingView {
                    vm.showOnboarding = false
                    vm.requestPermission()
                }

            } else if vm.status == .denied || vm.status == .restricted {

                LocationPermissionBlocker {
                    vm.requestPermission()
                }
            }
        }
    }
}


#Preview {
    MapView()
}
