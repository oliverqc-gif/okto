import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignup = false

    var body: some View {
        ZStack {
            // Background
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
                Spacer()

                // Mascot placeholder
                Image(systemName: "octopus.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))

                // Title
                Text("Okto")
                    .font(.system(size: 42, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))

                // Tagline
                Text("Finansnyheder der passer til dig. Personlig, smart og altid relevant.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Buttons
                Button(action: { showSignup = true }) {
                    Text("Opret konto")
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
                        .cornerRadius(10)
                }

                Button(action: { showSignup = true }) {
                    Text("Log ind")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.transparent)
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                        .font(.system(size: 16, weight: .semibold))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color(red: 0.27, green: 0.23, blue: 0.32),
                                    lineWidth: 2
                                )
                        )
                }

                Spacer()
                    .frame(height: 40)
            }
            .padding(28)
        }
        .sheet(isPresented: $showSignup) {
            SignupView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
