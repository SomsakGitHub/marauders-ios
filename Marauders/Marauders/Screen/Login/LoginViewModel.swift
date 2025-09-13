import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userEmail: String?

    func signInWithApple() {
        // เรียก flow Apple
    }

    func signInWithGoogle() {
        // เรียก flow Google
    }

    func signOut() {
        // clear token
        isLoggedIn = false
        userEmail = nil
    }
}
