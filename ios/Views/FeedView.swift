import SwiftUI

struct FeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var feedViewModel = FeedViewModel()
    @State private var showProfile = false

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

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "octopus.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))

                    Text("Hej, \(authViewModel.currentUser?.first_name ?? "Thomas")")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 38, height: 38)
                            .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(12)
                            .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                    }

                    Button(action: {}) {
                        Image(systemName: "bell")
                            .frame(width: 38, height: 38)
                            .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(12)
                            .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 3)

                // Date
                HStack {
                    Text(formattedDate())
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)

                // Category pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        let categories = ["Til dig", "Bolig", "Lån & renter", "Skat", "Opsparing", "Transport"]
                        ForEach(categories, id: \.self) { category in
                            Button(action: { feedViewModel.selectedCategory = category }) {
                                Text(category)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(8, 16)
                                    .background(feedViewModel.selectedCategory == category ? Color(red: 0.94, green: 0.63, blue: 0.19) : Color(red: 0.18, green: 0.15, blue: 0.22))
                                    .cornerRadius(10)
                                    .foregroundColor(feedViewModel.selectedCategory == category ? Color(red: 0.1, green: 0.06, blue: 0.07) : Color(red: 0.69, green: 0.66, blue: 0.59))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .scrollTargetBehavior(.viewAligned)

                // News Feed
                if feedViewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(Color(red: 0.94, green: 0.63, blue: 0.19))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(feedViewModel.filterArticlesByCategory(feedViewModel.selectedCategory)) { article in
                                NewsCardView(article: article)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                }

                Spacer()
            }
        }
        .task {
            if let userId = authViewModel.userId {
                await feedViewModel.loadFeed(userId: userId)
            }
        }
        .refreshable {
            if let userId = authViewModel.userId {
                await feedViewModel.refreshFeed(userId: userId)
            }
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "da_DK")
        formatter.dateFormat = "EEEE, d. MMMM yyyy"
        return formatter.string(from: Date())
    }
}

struct NewsCardView: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(sourceColor(article.source))
                            .frame(width: 8, height: 8)

                        Text(article.source)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                            .textCase(.uppercase)
                    }

                    Text(article.published_at.components(separatedBy: "T").first ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                }

                Spacer()
            }

            // Title
            Text(article.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                .lineLimit(2)

            // AI Insight
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Image(systemName: "octopus.fill")
                        .font(.system(size: 10))
                    Text("Personlig indsigt")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))

                Text("Denne nyhed kan være relevant for din økonomi baseret på din profil.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
            }
            .padding(12)
            .background(Color(red: 0.22, green: 0.18, blue: 0.26))
            .cornerRadius(8)

            // Tags
            HStack(spacing: 6) {
                ForEach(["Finans", "Marked"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(4, 10)
                        .background(Color(red: 0.22, green: 0.18, blue: 0.26))
                        .cornerRadius(6)
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                }
            }
        }
        .padding(18)
        .background(Color(red: 0.18, green: 0.15, blue: 0.22))
        .cornerRadius(20)
    }

    private func sourceColor(_ source: String) -> Color {
        switch source.lowercased() {
        case let s where s.contains("ecb") || s.contains("reuters"):
            return Color(red: 0.31, green: 0.56, blue: 0.82)
        case let s where s.contains("dr"):
            return Color(red: 0.88, green: 0.31, blue: 0.31)
        case let s where s.contains("børsen"):
            return Color(red: 0.69, green: 0.66, blue: 0.59)
        default:
            return Color(red: 0.88, green: 0.35, blue: 0.26)
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthViewModel())
}
