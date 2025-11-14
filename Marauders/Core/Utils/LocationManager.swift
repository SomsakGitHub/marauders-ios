import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            if locationManager.authorizationStatus == .authorizedAlways ||
               locationManager.authorizationStatus == .authorizedWhenInUse {
                
                // Map ใช้งานได้
                Map(position: .constant(.automatic))
                    .edgesIgnoringSafeArea(.all)
                
            } else if locationManager.authorizationStatus == .denied ||
                      locationManager.authorizationStatus == .restricted {
                
                // หน้าบล็อก
                LocationPermissionBlocker {
                    locationManager.requestPermission() // เรียกใหม่
                }
            } else {
                
                // กำลังตรวจสอบ
                ProgressView("Checking Permission...")
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

#Preview {
    MapView()
}

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

import SwiftUI

struct LocationPermissionBlocker: View {
    var onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Location Access Needed")
                .font(.largeTitle).bold()
            
            Text("To show your position on the map, please enable location access in Settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button {
                    openSettings()
                } label: {
                    Text("Open Settings")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
//                Button("Try Again") {
//                    onRetry()
//                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
}





