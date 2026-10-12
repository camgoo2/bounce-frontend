//
//  bounce_frontendApp.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

import SwiftUI

@main
struct bounce_frontendApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var isLoggedIn = KeychainHelper.shared.isLoggedIn()

    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            SignInView()
        }
    }
}


