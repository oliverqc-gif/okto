import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isLogin = false
    @State private var firstName = "Thomas"
    @State private var lastName = "Nielsen"
    @State private var email = "thomas@eksempel.dk"
    @State private var password = "password123"
    @State private var confirmPassword = "password123"

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
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Tilbage")
                        }
                        .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                        .font(.system(size: 15, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.bottom, 22)

                // Title
                VStack(alignment: .leading, spacing: 5) {
                    Text(isLogin ? "Log ind" : "Opret din konto")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))

                    Text(isLogin ? "Velkommen tilbage" : "Kom i gang med personlige finansnyheder")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.69, green: 0.66, blue: 0.59))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 28)

                // Form fields
                ScrollView {
                    VStack(spacing: 18) {
                        if !isLogin {
                            // First name
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Fornavn")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                                    .textCase(.uppercase)

                                TextField("", text: $firstName)
                                    .padding(14)
                                    .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                            }

                            // Last name
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Efternavn")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                                    .textCase(.uppercase)

                                TextField("", text: $lastName)
                                    .padding(14)
                                    .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                            }
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 7) {
                            Text("E-mail")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                                .textCase(.uppercase)

                            TextField("", text: $email)
                                .padding(14)
                                .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                                .cornerRadius(8)
                                .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                                .keyboardType(.emailAddress)
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Adgangskode")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                                .textCase(.uppercase)

                            SecureField("", text: $password)
                                .padding(14)
                                .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                                .cornerRadius(8)
                                .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                        }

                        if !isLogin {
                            // Confirm password
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Bekræft adgangskode")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                                    .textCase(.uppercase)

                                SecureField("", text: $confirmPassword)
                                    .padding(14)
                                    .background(Color(red: 0.18, green: 0.15, blue: 0.22))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(red: 0.94, green: 0.88, blue: 0.87))
                            }
                        }

                        // Error message
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }

                        // Action button
                        Button(action: {
                            if isLogin {
                                Task {
                                    await authViewModel.login(
                                        email: email,
                                        password: password
                                    )
                                }
                            } else {
                                Task {
                                    await authViewModel.signup(
                                        firstName: firstName,
                                        lastName: lastName,
                                        email: email,
                                        password: password
                                    )
                                }
                            }
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(Color(red: 0.1, green: 0.06, blue: 0.07))
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                            } else {
                                Text(isLogin ? "Log ind" : "Opret konto")
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

                        // Toggle between signup and login
                        HStack(spacing: 4) {
                            Text(isLogin ? "Ikke medlem?" : "Allerede medlem?")
                                .foregroundColor(Color(red: 0.47, green: 0.43, blue: 0.38))
                            Button(action: { isLogin.toggle() }) {
                                Text(isLogin ? "Opret konto" : "Log ind")
                                    .foregroundColor(Color(red: 0.94, green: 0.63, blue: 0.19))
                            }
                        }
                        .font(.system(size: 12))
                        .padding(.top, 12)
                    }
                }
            }
            .padding(28)
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
}
