import SwiftUI

struct LocationOnboardingView: View {
    @State private var fadeIn = false
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(systemName: "location.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 0.8), value: fadeIn)
            
            Text("Enable Location")
                .font(.system(.largeTitle, design: .rounded)).bold()
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 1.0).delay(0.1), value: fadeIn)
            
            Text("We use your location to show your position on the map and track your route.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 1.0).delay(0.2), value: fadeIn)
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .opacity(fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 1.0).delay(0.35), value: fadeIn)
        }
        .padding()
        .onAppear { fadeIn = true }
    }
}
