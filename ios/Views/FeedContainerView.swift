import SwiftUI

struct FeedContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var showProfileSetup = false

    var body: some View {
        ZStack {
            // Check if profile is incomplete
            if authViewModel.currentProfile?.age == nil && !showProfileSetup {
                ProfileSetupView()
                    .environmentObject(authViewModel)
            } else {
                TabView(selection: $selectedTab) {
                    // Feed Tab
                    FeedView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Feed")
                        }
                        .tag(0)

                    // Explore Tab
                    ExploreView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Udforsk")
                        }
                        .tag(1)

                    // Insights Tab
                    InsightsView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Indsigter")
                        }
                        .tag(2)

                    // Profile Tab
                    ProfileView()
                        .environmentObject(authViewModel)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profil")
                        }
                        .tag(3)
                }
                .accentColor(Color(red: 0.94, green: 0.63, blue: 0.19))
            }
        }
    }
}

// Placeholder views for other tabs
struct ExploreView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.06, blue: 0.07),
                    Color(red: 0.18, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Text("Udforsk")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                Text("Coming Soon")
                    .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
            }
        }
    }
}

struct InsightsView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.06, blue: 0.07),
                    Color(red: 0.18, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Text("Indsigter")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                Text("Coming Soon")
                    .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.06, blue: 0.07),
                    Color(red: 0.18, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Profil")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))

                if let user = authViewModel.currentUser {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Navn:")
                                .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                            Spacer()
                            Text("\(user.first_name) \(user.last_name)")
                                .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                        }

                        HStack {
                            Text("E-mail:")
                                .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                            Spacer()
                            Text(user.email)
                                .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                        }
                    }
                    .padding(16)
                    .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                    .cornerRadius(10)
                }

                Spacer()

                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log ud")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0.88, green: 0.31, blue: 0.31))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding(28)
        }
    }
}

#Preview {
    FeedContainerView()
        .environmentObject(AuthViewModel())
}
