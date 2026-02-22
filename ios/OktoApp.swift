import SwiftUI

@main
struct OktoApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                FeedContainerView()
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
