import SwiftUI

struct LocationPermissionBlocker: View {
    @State private var fadeIn = false
    var onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .padding(.bottom, 10)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 0.8), value: fadeIn)
            
            Text("Location Disabled")
                .font(.largeTitle.bold())
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 1.0).delay(0.1), value: fadeIn)

            Text("Please enable location access in Settings to continue using the map.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 1.0).delay(0.2), value: fadeIn)

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
                
//                Button("Try Again") { onRetry() }
//                    .padding(.top, 4)
            }
            .padding(.horizontal)
            .opacity(fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 1.0).delay(0.35), value: fadeIn)
        }
        .padding()
        .onAppear { fadeIn = true }
    }
}

private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
}
