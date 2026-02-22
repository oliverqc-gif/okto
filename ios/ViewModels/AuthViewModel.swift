import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userId: Int?

    private let apiService = APIService.shared

    init() {
        // Check if user is already logged in
        if UserDefaults.standard.string(forKey: "authToken") != nil {
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Sign Up

    func signup(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.signup(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )

            userId = response.user_id
            await loadCurrentUser()
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Log In

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            userId = response.user_id
            await loadCurrentUser()
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Log Out

    func logout() {
        apiService.logout()
        isAuthenticated = false
        currentUser = nil
        currentProfile = nil
        userId = nil
        errorMessage = nil
    }

    // MARK: - Load User Data

    private func loadCurrentUser() async {
        do {
            let user = try await apiService.getCurrentUser()
            currentUser = user
            userId = user.id

            // Also load profile
            let profile = try await apiService.getProfile(userId: user.id)
            currentProfile = profile

            isAuthenticated = true
            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Profile Updates

    func updateProfile(
        age: Int? = nil,
        region: String? = nil,
        employment: String? = nil,
        income: Double? = nil,
        housingType: String? = nil,
        housingValue: Double? = nil,
        loanTypes: [String]? = nil,
        numLoans: Int? = nil,
        totalDebt: Double? = nil,
        interestRateType: String? = nil,
        vehicleType: String? = nil,
        savingsTypes: [String]? = nil,
        insuranceTypes: [String]? = nil,
        breakingNews: Bool? = nil,
        dailyDigest: Bool? = nil,
        aiInsights: Bool? = nil
    ) async {
        guard let userId = userId else {
            errorMessage = "User ID not available"
            return
        }

        let profileData = ProfileUpdateRequest(
            age: age,
            region: region,
            employment: employment,
            annual_gross_income: income,
            housing_type: housingType,
            housing_value: housingValue,
            loan_types: loanTypes,
            num_loans: numLoans,
            total_debt: totalDebt,
            interest_rate_type: interestRateType,
            vehicle_type: vehicleType,
            savings_types: savingsTypes,
            insurance_types: insuranceTypes,
            breaking_news: breakingNews,
            daily_digest: dailyDigest,
            ai_insights: aiInsights
        )

        do {
            try await apiService.updateProfile(userId: userId, profileData: profileData)
            // Reload profile
            let updatedProfile = try await apiService.getProfile(userId: userId)
            currentProfile = updatedProfile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
