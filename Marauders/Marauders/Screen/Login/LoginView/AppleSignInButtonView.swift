import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    var body: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        }, onCompletion: { result in
            switch result {
            case .success(let authResults):
                if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                    let userId = credential.user
                    let email = credential.email
                    print("Apple UserID: \(userId), Email: \(email ?? "-")")
                }
            case .failure(let error):
                print("Apple login failed: \(error.localizedDescription)")
            }
        })
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(8)
    }
}


#Preview {
    AppleSignInButtonView()
}
