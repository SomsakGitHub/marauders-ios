import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showOnboarding = true
    @State private var isMapReady = false

    var body: some View {
        ZStack {
            
            // 1) Authorized → แสดง Map
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways {

                ZStack {
                    
//                    Map(position: .constant(.automatic))
//                        .edgesIgnoringSafeArea(.all)
                    
                    CustomMap(onMapReady: {
                        withAnimation { isMapReady = true }
                    })

                    if !isMapReady {
                        ProgressView("Loading Map...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .transition(.opacity)
                    }
                }
            }
            
            // 2) ถ้าเป็น .notDetermined และ showOnboarding = true → แสดง onboarding
            else if showOnboarding {
                LocationOnboardingView {
                    showOnboarding = false
                    locationManager.requestPermission()
                }
                .background(.ultraThinMaterial)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: showOnboarding)
            }
            
            // 3) ถ้า Denied → โชว์ Blocker
            else if locationManager.authorizationStatus == .denied ||
               locationManager.authorizationStatus == .restricted {
                LocationPermissionBlocker {
                    locationManager.requestPermission()
                }
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: locationManager.authorizationStatus)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status, _ in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                withAnimation { showOnboarding = false }
            }
        }
    }
}

#Preview {
    MapView()
}
