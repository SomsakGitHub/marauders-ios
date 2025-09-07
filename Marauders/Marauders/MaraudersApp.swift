import SwiftUI

@main
struct MaraudersApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    
    var isLogin = false

    var body: some View {
        if isLogin {
            RegisterView()
            //            MainTabView().environmentObject(authentication)
        } else {
            LoginView()
//            LoginSceneView().environmentObject(authentication)
        }
    }
}
