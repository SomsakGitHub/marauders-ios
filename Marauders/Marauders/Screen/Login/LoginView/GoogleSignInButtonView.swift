import SwiftUI
import GoogleSignInSwift

struct GoogleSignInButtonView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoggedIn {
                Text("Welcome, \(viewModel.userEmail ?? "-")")
                Button("Sign Out") {
                    viewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
            } else {
                GoogleSignInButton {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }
                .frame(height: 50)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}



#Preview {
    GoogleSignInButtonView()
}
