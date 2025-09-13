import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInButtonView: View {
    var body: some View {
        GoogleSignInButton {
//            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//            let config = GIDConfiguration(clientID: clientID)
            
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("Google login failed: \(error.localizedDescription)")
                    return
                }
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else { return }
                
                print("Google UserID: \(user.userID ?? "-"), Token: \(idToken)")
            }
        }
        .frame(height: 50)
        .cornerRadius(8)
    }
}


#Preview {
    GoogleSignInButtonView()
}
