import SwiftUI

struct LoginView: View {
//    @StateObject private var viewModel = LoginViewModel()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(8)

                Button(action: handleLogin) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // 👉 ปุ่มไป Register
                NavigationLink(destination: RegisterView()) {
                    Text("Don’t have an account? Sign up")
                        .foregroundColor(.blue)
                        .underline()
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Failed"), message: Text("Invalid email or password."), dismissButton: .default(Text("OK")))
            }
//            .navigationBarHidden(true)
        }
    }

    func handleLogin() {
//        viewModel.login { success in
//            authentication.updateValidation(success: success)
//        }
//
        
//        if !viewModel.isLoggedIn {
//            HomeView()
//        }
        // Dummy validation
//        if email == "test@example.com" && password == "password123" {
//            isLoggedIn = true
//        } else {
//            showAlert = true
//        }
    }
}

#Preview {
    LoginView()
}
