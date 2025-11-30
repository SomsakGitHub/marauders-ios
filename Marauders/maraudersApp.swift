//
//  MaraudersApp.swift
//  Marauders
//
//  Created by tiscomacnb2486 on 12/11/2568 BE.
//

import SwiftUI
import SwiftData

@main
struct MaraudersApp: App {
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
            MapView(viewModel: MapViewDIContainer.shared.makeMapViewModel())
        }
        .modelContainer(sharedModelContainer)
    }
}
