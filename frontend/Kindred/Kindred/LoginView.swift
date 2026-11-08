
import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    // NAVIGATION STATE
    @State private var isLoggedIn = false
    @State private var showMainApp = false

    let forestGreen = Color(
        red: 0.12,
        green: 0.28,
        blue: 0.20
    )

    let cream = Color(
        red: 0.97,
        green: 0.96,
        blue: 0.91
    )

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // FULL-SCREEN BACKGROUND
                Image("WelcomeBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // FULL-WIDTH TRANSLUCENT TITLE BAND
                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text("Welcome Back")
                            .font(
                                .system(
                                    size: 38,
                                    weight: .bold
                                )
                            )

                        Text("Log in to continue connecting.")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .semibold
                                )
                            )
                    }
                    .foregroundStyle(forestGreen)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                    .padding(.top, 190)
                    .padding(.bottom, 25)

                    // LOGIN FORM
                    VStack(spacing: 20) {

                        // EMAIL
                        TextField(
                            "Email",
                            text: $email
                        )
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(cream.opacity(0.9))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                        )

                        // PASSWORD
                        SecureField(
                            "Password",
                            text: $password
                        )
                        .textContentType(.password)
                        .padding()
                        .background(cream.opacity(0.9))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                        )

                        // ERROR MESSAGE
                        if let errorMessage {

                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(cream.opacity(0.95))
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )
                        }

                        // LOGIN BUTTON
                        Button {

                            Task {
                                await performLogin()
                            }

                        } label: {

                            HStack(spacing: 10) {

                                if isLoading {
                                    ProgressView()
                                        .tint(cream)
                                }

                                Text(
                                    isLoading
                                        ? "Logging In..."
                                        : "Log In"
                                )
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )

                                if !isLoading {
                                    Image(
                                        systemName: "arrow.right"
                                    )
                                }
                            }
                            .foregroundStyle(cream)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(forestGreen)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )
                        }
                        .disabled(
                            isLoading ||
                            email.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty ||
                            password.isEmpty
                        )
                        .opacity(isLoading ? 0.75 : 1)
                    }
                    .padding(.horizontal, 28)

                    Spacer()
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }

        // LOGIN SUCCESS ALERT
        .alert(
            "Login Successful",
            isPresented: $isLoggedIn
        ) {

            Button("Continue to Kindred") {
                showMainApp = true
            }

        } message: {

            Text(
                "Welcome back! You're now connected to Kindred."
            )
        }

        // OPEN MAIN APP AFTER SUCCESSFUL LOGIN
        .fullScreenCover(isPresented: $showMainApp) {

            MainTabView()
                .interactiveDismissDisabled()
        }
    }

    // MARK: - BACKEND LOGIN

    @MainActor
    private func performLogin() async {

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            // AUTHENTICATE WITH EXISTING BACKEND
            try await AuthService.shared.login(
                email: email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                password: password
            )

            // VERIFY THE JWT WAS SAVED
            guard AuthService.shared.getSavedToken() != nil else {
                errorMessage =
                    "Login succeeded, but your session was not saved."
                return
            }

            // CLEAR SENSITIVE INPUT
            password = ""

            // SHOW SUCCESS ALERT
            isLoggedIn = true

        } catch {

            errorMessage = error.localizedDescription

            print("Login failed:", error)
        }
    }
}

// MARK: - PREVIEW

#Preview {
    NavigationStack {
        LoginView()
    }
}
