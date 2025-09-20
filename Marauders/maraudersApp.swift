import SwiftUI
import SwiftData

@main
struct maraudersApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
//            ContentView()
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    
    var isLogin = false

    var body: some View {
        if isLogin {
//            MainTabView().environmentObject(authentication)
        } else {
            MainTabView()
        }
    }
}
