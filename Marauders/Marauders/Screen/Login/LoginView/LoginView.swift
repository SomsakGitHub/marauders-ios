import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Login Page")
                .font(.largeTitle)

            AppleSignInButtonView()
            GoogleSignInButtonView()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
