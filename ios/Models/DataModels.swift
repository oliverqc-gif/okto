import Foundation

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let first_name: String
    let last_name: String
}

struct SignupRequest: Codable {
    let first_name: String
    let last_name: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let user_id: Int
}

// MARK: - Profile Models

struct UserProfile: Codable, Identifiable {
    let id: Int
    let user_id: Int
    var age: Int?
    var region: String?
    var employment: String?
    var annual_gross_income: Double?
    var housing_type: String?
    var housing_value: Double?
    var loan_types: [String]?
    var num_loans: Int?
    var total_debt: Double?
    var interest_rate_type: String?
    var vehicle_type: String?
    var savings_types: [String]?
    var insurance_types: [String]?
    var breaking_news: Bool = true
    var daily_digest: Bool = true
    var ai_insights: Bool = true
}

struct ProfileUpdateRequest: Codable {
    var age: Int?
    var region: String?
    var employment: String?
    var annual_gross_income: Double?
    var housing_type: String?
    var housing_value: Double?
    var loan_types: [String]?
    var num_loans: Int?
    var total_debt: Double?
    var interest_rate_type: String?
    var vehicle_type: String?
    var savings_types: [String]?
    var insurance_types: [String]?
    var breaking_news: Bool?
    var daily_digest: Bool?
    var ai_insights: Bool?
}

// MARK: - News Models

struct NewsArticle: Codable, Identifiable {
    let id: Int
    let source: String
    let title: String
    let description: String
    let url: String
    let image_url: String?
    let published_at: String
    let category: String
    let author: String?
}

struct NewsResponse: Codable {
    let articles: [NewsArticle]
}

// MARK: - Insight Models

struct Insight: Codable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let type: String  // "opportunity", "benefit", "market", "alert"
}

struct InsightsResponse: Codable {
    let insights: [Insight]
}

struct NewsSource: Codable {
    let sources: [String]
}

// MARK: - App State

enum ProfileStep {
    case step1  // Age, region, employment, income
    case step2  // Housing
    case step3  // Loans & vehicles
    case step4  // Savings & insurance
}

enum AppScreen {
    case welcome
    case signup
    case profileSetup
    case loading
    case feed
}
