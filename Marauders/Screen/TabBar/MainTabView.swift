import Combine
import SwiftUI

struct MainTabView: View {
//    @State private var selectedTabIndex = 0
    
    @StateObject var tabRouter = TabRouter()
    private let services: ServiceContainer
    
    init(services: ServiceContainer) {
        self.services = services
    }
    
    var body: some View {
        
        TabView(selection: $tabRouter.selectedTab) {
            FeedSceneView(services: services)
                .tabItem {
                    VStack {
                        Image(systemName: tabRouter.selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, tabRouter.selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }
                }
                .onAppear {
                    tabRouter.selectedTab = 0
                }
                .tag(0)
//            LocationSceneView()
                .tabItem {
                    VStack {
                        Image(systemName: tabRouter.selectedTab == 1 ? "house.fill" : "house")
                            .environment(\.symbolVariants, tabRouter.selectedTab == 1 ? .fill : .none)
                        Text("Location")
                    }
                }
                .onAppear {
                    tabRouter.selectedTab = 1
                }
                .tag(1)
        }
        .tint(.black)
        .environmentObject(tabRouter) // แชร์ให้ลูก View
//        TabView {
//            ZStack {
//                PlayerView()
//                HStack {
//                    Spacer()
//                    ReactionButtons1View()
//                }
//                .frame(width: UIScreen.main.bounds.width)
//            }
//            
//            ZStack {
//                ThirdVideoView()
//                HStack {
//                    Spacer()
//                    ReactionButtons3View()
//                }
//                .frame(width: UIScreen.main.bounds.width)
//            }
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .ignoresSafeArea()
    }
}

#Preview {
    
    MainTabView(services: ServiceContainer())
}

class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0
}

