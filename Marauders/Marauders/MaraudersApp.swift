//
//  MaraudersApp.swift
//  Marauders
//
//  Created by tiscomacnb2486 on 6/9/2568 BE.
//

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
            //            MainTabView().environmentObject(authentication)
        } else {
            ContentView()
//            LoginSceneView().environmentObject(authentication)
        }
    }
}
