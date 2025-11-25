import SwiftUI
import CoreLocation

struct MapMainView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            
            // 1) Authorized → แสดง MarauderMap
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                
                MarauderMapView(locationManager: locationManager,
                                friends: [
                                    MapPoint(coordinate: CLLocationCoordinate2D(latitude: 13.757, longitude: 100.502)),
                                    MapPoint(coordinate: CLLocationCoordinate2D(latitude: 13.755, longitude: 100.503))
                                ])
            }
            
            // 2) Onboarding
            else if showOnboarding {
                LocationOnboardingView {
                    showOnboarding = false
                    locationManager.requestPermission()
                }
                .background(.ultraThinMaterial)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: showOnboarding)
            }
            
            // 3) Permission Denied → Blocker
            else if locationManager.authorizationStatus == .denied ||
                    locationManager.authorizationStatus == .restricted {
                
                LocationPermissionBlocker {
                    locationManager.requestPermission()
                }
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: locationManager.authorizationStatus)
            } else {
                ProgressView("Checking Permission...")
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                withAnimation { showOnboarding = false }
            }
        }
    }
}

