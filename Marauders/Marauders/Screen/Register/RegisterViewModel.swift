import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false
    
    func register() {
        // ตรวจสอบ validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "กรุณากรอกข้อมูลให้ครบ"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "รหัสผ่านไม่ตรงกัน"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "อีเมลไม่ถูกต้อง"
            return
        }
        
        // สมมติว่าเรียก API สมัครสมาชิก
        // ตรงนี้คุณสามารถเชื่อม Firebase Auth หรือ Backend ของคุณเองได้
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRegistered = true
            self.errorMessage = nil
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}


