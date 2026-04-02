import Foundation
import SwiftUI
import SwiftData

@main
struct MaraudersApp: App {
    
    var isPass = false
    
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
    
    let container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            AppCoordinator(container: container)
        }.modelContainer(sharedModelContainer)
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

struct MainTabView: View {

    let container: AppDIContainer
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            container.makeFeedView(selectedTab: selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            container.mapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)

            container.videoPickerView()
                .tabItem {
                    Label("Upload", systemImage: "plus.square")
                }
                .tag(2)

            container.profileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}
