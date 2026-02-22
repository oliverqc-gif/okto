import Foundation

class APIService: ObservableObject {
    static let shared = APIService()

    private let baseURL = "http://localhost:8000"  // Change for production
    private var authToken: String?

    init() {
        // Try to load token from UserDefaults
        authToken = UserDefaults.standard.string(forKey: "authToken")
    }

    // MARK: - Authentication

    func signup(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> AuthResponse {
        let request = SignupRequest(
            first_name: firstName,
            last_name: lastName,
            email: email,
            password: password
        )

        let response = try await post(
            endpoint: "/auth/signup",
            body: request,
            responseType: AuthResponse.self
        )

        // Save token
        authToken = response.access_token
        UserDefaults.standard.set(response.access_token, forKey: "authToken")

        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)

        let response = try await post(
            endpoint: "/auth/login",
            body: request,
            responseType: AuthResponse.self
        )

        // Save token
        authToken = response.access_token
        UserDefaults.standard.set(response.access_token, forKey: "authToken")

        return response
    }

    func logout() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }

    func getCurrentUser() async throws -> User {
        return try await get(
            endpoint: "/users/me",
            responseType: User.self
        )
    }

    // MARK: - Profile

    func getProfile(userId: Int) async throws -> UserProfile {
        return try await get(
            endpoint: "/users/\(userId)/profile",
            responseType: UserProfile.self
        )
    }

    func updateProfile(userId: Int, profileData: ProfileUpdateRequest) async throws {
        try await put(
            endpoint: "/users/\(userId)/profile",
            body: profileData
        )
    }

    // MARK: - News

    func getNewsFeed(userId: Int, limit: Int = 20) async throws -> [NewsArticle] {
        let urlString = "\(baseURL)/news/feed?user_id=\(userId)&limit=\(limit)&token=\(authToken ?? "")"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.serverError
        }

        let articles = try JSONDecoder().decode([NewsArticle].self, from: data)
        return articles
    }

    func getNewsSources() async throws -> [String] {
        let response = try await get(
            endpoint: "/news/sources",
            responseType: NewsSource.self
        )
        return response.sources
    }

    func refreshNews() async throws {
        try await post(
            endpoint: "/news/refresh",
            body: EmptyRequest(),
            responseType: EmptyResponse.self
        )
    }

    // MARK: - Insights

    func getInsights(userId: Int) async throws -> [Insight] {
        let response = try await get(
            endpoint: "/insights/\(userId)",
            responseType: InsightsResponse.self
        )
        return response.insights
    }

    // MARK: - Helper Methods

    private func get<T: Decodable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeader(&request)

        let (data, response) = try await URLSession.shared.data(for: request)

        try validateResponse(response)

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    private func post<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T,
        responseType: R.Type
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(&request)

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        try validateResponse(response)

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    private func put<T: Encodable>(
        endpoint: String,
        body: T
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(&request)

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        try validateResponse(response)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            logout()
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknownError
        }
    }

    private func addAuthHeader(_ request: inout URLRequest) {
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: - Error Handling

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case unauthorized
    case notFound
    case serverError
    case unknownError
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later."
        case .unknownError:
            return "An unknown error occurred"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Helper Structures

struct EmptyRequest: Codable {}

struct EmptyResponse: Codable {}
