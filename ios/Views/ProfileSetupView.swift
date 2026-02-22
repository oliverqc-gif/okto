import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep: ProfileStep = .step1
    @State private var isLoading = false

    // Step 1
    @State private var age = 32
    @State private var region = "Hovedstaden"
    @State private var employment = "Lønmodtager"
    @State private var income = 450.0

    // Step 2
    @State private var housingType = "Andelsbolig"
    @State private var housingValue = 2.2

    // Step 3
    @State private var loanTypes: [String] = ["Boliglån", "Andelslån"]
    @State private var numLoans = 2
    @State private var totalDebt = 1.8
    @State private var interestRateType = "Fast"
    @State private var vehicleType = "Elbil"

    // Step 4
    @State private var savingsTypes: [String] = ["Aktiesparekonto", "Friværdi"]
    @State private var insuranceTypes: [String] = ["Indboforsikring", "Bilforsikring"]
    @State private var breakingNews = true
    @State private var dailyDigest = true
    @State private var aiInsights = true

    let regions = ["Hovedstaden", "Midtjylland", "Nordjylland", "Sjælland", "Syddanmark"]
    let employmentOptions = ["Lønmodtager", "Selvstændig", "Studerende", "Pensioneret"]
    let housingOptions = ["Lejebolig", "Andelsbolig", "Ejerbolig", "Sommerhus"]
    let vehicleOptions = ["Benzin/diesel", "Elbil", "Cykel/offentlig", "Hybrid"]
    let allLoanTypes = ["Boliglån", "Billån", "Andelslån", "Forbrugslån", "SU-lån", "Kassekredit"]
    let allSavingsTypes = ["Aktiesparekonto", "Pension", "Friværdi", "Krypto", "Ratepension", "Aldersopsparing"]
    let allInsuranceTypes = ["Indboforsikring", "Bilforsikring", "Sundhedsforsikring", "Livsforsikring", "Rejseforsikring"]

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
                // Progress bar
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(stepFillColor(for: index))
                            .frame(height: 5)
                    }
                }
                .padding(.bottom, 26)

                // Title
                VStack(alignment: .leading, spacing: 5) {
                    Text(stepTitle)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))

                    Text(stepSubtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 26)

                // Content
                ScrollView {
                    switch currentStep {
                    case .step1:
                        Step1View(
                            age: $age,
                            region: $region,
                            employment: $employment,
                            income: $income,
                            regions: regions,
                            employmentOptions: employmentOptions
                        )
                    case .step2:
                        Step2View(
                            housingType: $housingType,
                            housingValue: $housingValue,
                            housingOptions: housingOptions
                        )
                    case .step3:
                        Step3View(
                            loanTypes: $loanTypes,
                            numLoans: $numLoans,
                            totalDebt: $totalDebt,
                            interestRateType: $interestRateType,
                            vehicleType: $vehicleType,
                            allLoanTypes: allLoanTypes,
                            vehicleOptions: vehicleOptions
                        )
                    case .step4:
                        Step4View(
                            savingsTypes: $savingsTypes,
                            insuranceTypes: $insuranceTypes,
                            breakingNews: $breakingNews,
                            dailyDigest: $dailyDigest,
                            aiInsights: $aiInsights,
                            allSavingsTypes: allSavingsTypes,
                            allInsuranceTypes: allInsuranceTypes
                        )
                    }
                }

                Spacer()

                // Buttons
                HStack(spacing: 12) {
                    if currentStep != .step1 {
                        Button(action: previousStep) {
                            Text("Tilbage")
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 0.27, green: 0.23, blue: 0.32), lineWidth: 2)
                                )
                        }
                    }

                    Button(action: nextOrFinish) {
                        if isLoading {
                            ProgressView()
                                .tint(Color(red: 0.1, green: 0.06, blue: 0.07))
                                .frame(maxWidth: .infinity)
                                .padding(16)
                        } else {
                            Text(currentStep == .step4 ? "Færdig" : "Næste")
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.94, green: 0.63, blue: 0.19),
                                            Color(red: 0.78, green: 0.5, blue: 0.12)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(Color(red: 0.1, green: 0.06, blue: 0.07))
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .cornerRadius(10)
                }
            }
            .padding(28)
        }
    }

    // MARK: - Helper Methods

    private var stepTitle: String {
        switch currentStep {
        case .step1: return "Om dig"
        case .step2: return "Bolig"
        case .step3: return "Lån & køretøjer"
        case .step4: return "Opsparing & mere"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case .step1: return "Grundlæggende oplysninger."
        case .step2: return "Fortæl os om din boligsituation."
        case .step3: return "Oplysninger om lån og transport."
        case .step4: return "Sidste trin!"
        }
    }

    private func stepFillColor(for index: Int) -> Color {
        let stepIndex = currentStepIndex
        if index < stepIndex {
            return Color(red: 0.94, green: 0.63, blue: 0.19)
        } else if index == stepIndex {
            return Color(red: 0.94, green: 0.63, blue: 0.19)
        } else {
            return Color(red: 0.22, green: 0.18, blue: 0.26)
        }
    }

    private var currentStepIndex: Int {
        switch currentStep {
        case .step1: return 0
        case .step2: return 1
        case .step3: return 2
        case .step4: return 3
        }
    }

    private func nextStep() {
        switch currentStep {
        case .step1: currentStep = .step2
        case .step2: currentStep = .step3
        case .step3: currentStep = .step4
        case .step4: break
        }
    }

    private func previousStep() {
        switch currentStep {
        case .step1: break
        case .step2: currentStep = .step1
        case .step3: currentStep = .step2
        case .step4: currentStep = .step3
        }
    }

    private func nextOrFinish() {
        if currentStep == .step4 {
            finishOnboarding()
        } else {
            nextStep()
        }
    }

    private func finishOnboarding() {
        isLoading = true

        Task {
            await authViewModel.updateProfile(
                age: age,
                region: region,
                employment: employment,
                income: income * 1000,
                housingType: housingType,
                housingValue: housingValue * 1_000_000,
                loanTypes: loanTypes,
                numLoans: numLoans,
                totalDebt: totalDebt * 1_000_000,
                interestRateType: interestRateType,
                vehicleType: vehicleType,
                savingsTypes: savingsTypes,
                insuranceTypes: insuranceTypes,
                breakingNews: breakingNews,
                dailyDigest: dailyDigest,
                aiInsights: aiInsights
            )
            isLoading = false
        }
    }
}

// MARK: - Step Views

struct Step1View: View {
    @Binding var age: Int
    @Binding var region: String
    @Binding var employment: String
    @Binding var income: Double
    let regions: [String]
    let employmentOptions: [String]

    var body: some View {
        VStack(spacing: 22) {
            // Age
            VStack(alignment: .leading, spacing: 7) {
                Text("Alder")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                HStack {
                    Text("\(age)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                    Text("år")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }

                Slider(value: Double($age), in: 18...75, step: 1)
            }

            // Region
            VStack(alignment: .leading, spacing: 7) {
                Text("Region")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                Picker("Region", selection: $region) {
                    ForEach(regions, id: \.self) { r in
                        Text(r).tag(r)
                    }
                }
                .pickerStyle(.menu)
            }

            // Employment
            VStack(alignment: .leading, spacing: 7) {
                Text("Beskæftigelse")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 10) {
                    ForEach(employmentOptions, id: \.self) { option in
                        Button(action: { employment = option }) {
                            HStack {
                                Text(option)
                                Spacer()
                                if employment == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(12)
                            .background(employment == option ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        }
                    }
                }
            }

            // Income
            VStack(alignment: .leading, spacing: 7) {
                Text("Årlig bruttoindkomst")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                HStack {
                    Text("\(Int(income))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                    Text(".000 kr.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }

                Slider(value: $income, in: 100...1500, step: 25)
            }
        }
    }
}

struct Step2View: View {
    @Binding var housingType: String
    @Binding var housingValue: Double
    let housingOptions: [String]

    var body: some View {
        VStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Boligtype")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 10) {
                    ForEach(housingOptions, id: \.self) { option in
                        Button(action: { housingType = option }) {
                            HStack {
                                Text(option)
                                Spacer()
                                if housingType == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(12)
                            .background(housingType == option ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Boligværdi (anslået)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                HStack {
                    Text(String(format: "%.1f", housingValue))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                    Text("mio. kr.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }

                Slider(value: $housingValue, in: 0.5...8, step: 0.1)
            }
        }
    }
}

struct Step3View: View {
    @Binding var loanTypes: [String]
    @Binding var numLoans: Int
    @Binding var totalDebt: Double
    @Binding var interestRateType: String
    @Binding var vehicleType: String
    let allLoanTypes: [String]
    let vehicleOptions: [String]

    var body: some View {
        VStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Låntyper")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 8) {
                    ForEach(allLoanTypes, id: \.self) { loanType in
                        Button(action: {
                            if loanTypes.contains(loanType) {
                                loanTypes.removeAll { $0 == loanType }
                            } else {
                                loanTypes.append(loanType)
                            }
                        }) {
                            HStack {
                                Text(loanType)
                                Spacer()
                                if loanTypes.contains(loanType) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(10)
                            .background(loanTypes.contains(loanType) ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Antal lån")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                HStack(spacing: 14) {
                    Button(action: { if numLoans > 0 { numLoans -= 1 } }) {
                        Text("-")
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.22, green: 0.18, blue: 0.26))
                            .cornerRadius(16)
                    }

                    Text("\(numLoans)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                        .frame(minWidth: 24)

                    Button(action: { if numLoans < 10 { numLoans += 1 } }) {
                        Text("+")
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.94, green: 0.63, blue: 0.19))
                            .cornerRadius(16)
                            .foregroundColor(Color(red: 0.1, green: 0.06, blue: 0.07))
                    }

                    Text("lån i alt")
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Samlet restgæld")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                HStack {
                    Text(String(format: "%.1f", totalDebt))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                    Text("mio. kr.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }

                Slider(value: $totalDebt, in: 0.1...6, step: 0.1)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Køretøj")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 10) {
                    ForEach(vehicleOptions, id: \.self) { option in
                        Button(action: { vehicleType = option }) {
                            HStack {
                                Text(option)
                                Spacer()
                                if vehicleType == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(12)
                            .background(vehicleType == option ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

struct Step4View: View {
    @Binding var savingsTypes: [String]
    @Binding var insuranceTypes: [String]
    @Binding var breakingNews: Bool
    @Binding var dailyDigest: Bool
    @Binding var aiInsights: Bool
    let allSavingsTypes: [String]
    let allInsuranceTypes: [String]

    var body: some View {
        VStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Opsparingstyper")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 8) {
                    ForEach(allSavingsTypes, id: \.self) { type in
                        Button(action: {
                            if savingsTypes.contains(type) {
                                savingsTypes.removeAll { $0 == type }
                            } else {
                                savingsTypes.append(type)
                            }
                        }) {
                            HStack {
                                Text(type)
                                Spacer()
                                if savingsTypes.contains(type) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(10)
                            .background(savingsTypes.contains(type) ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Forsikringer")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                VStack(spacing: 8) {
                    ForEach(allInsuranceTypes, id: \.self) { type in
                        Button(action: {
                            if insuranceTypes.contains(type) {
                                insuranceTypes.removeAll { $0 == type }
                            } else {
                                insuranceTypes.append(type)
                            }
                        }) {
                            HStack {
                                Text(type)
                                Spacer()
                                if insuranceTypes.contains(type) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                                }
                            }
                            .padding(10)
                            .background(insuranceTypes.contains(type) ? Color(red: 0.22, green: 0.18, blue: 0.26) : Color(red: 0.18, green: 0.15, blue: 0.22))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Notifikationer")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))

                NotificationToggleRow(title: "Breaking nyheder", subtitle: "Vigtige økonomiske nyheder", isOn: $breakingNews)
                NotificationToggleRow(title: "Daglig opsamling", subtitle: "Morgenoversigt kl. 07:30", isOn: $dailyDigest)
                NotificationToggleRow(title: "AI-indsigter", subtitle: "Personlige analysebeskeder", isOn: $aiInsights)
            }
        }
    }
}

struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color(red: 0.94, green: 0.63, blue: 0.19))
        }
        .padding(13)
        .background(Color(red: 0.18, green: 0.15, blue: 0.22))
        .cornerRadius(10)
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthViewModel())
}
