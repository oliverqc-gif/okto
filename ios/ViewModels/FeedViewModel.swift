import Foundation
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var insights: [Insight] = []
    @Published var sources: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory = "Til dig"

    private let apiService = APIService.shared
    private var refreshTimer: Timer?

    // MARK: - Load Data

    func loadFeed(userId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            async let articlesTask = apiService.getNewsFeed(userId: userId, limit: 20)
            async let insightsTask = apiService.getInsights(userId: userId)
            async let sourcesTask = apiService.getNewsSources()

            let (loadedArticles, loadedInsights, loadedSources) = try await (
                articlesTask,
                insightsTask,
                sourcesTask
            )

            articles = loadedArticles
            insights = loadedInsights
            sources = loadedSources
            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Refresh

    func refreshFeed(userId: Int) async {
        await loadFeed(userId: userId)
    }

    func manualRefreshNews() async {
        do {
            try await apiService.refreshNews()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Filtering

    func filterArticlesByCategory(_ category: String) -> [NewsArticle] {
        if category == "Til dig" {
            return articles
        }

        return articles.filter { article in
            article.category.lowercased().contains(category.lowercased())
        }
    }

    // MARK: - Cleanup

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    deinit {
        stopAutoRefresh()
    }
}
