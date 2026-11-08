
import SwiftUI

struct SignUpView: View {

    @Bindable var store: SignupStore

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var ageText = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var accountCreated = false
    @State private var showMainApp = false

    private let forestGreen = Color(
        red: 0.12, green: 0.28, blue: 0.20
    )

    private let cream = Color(
        red: 0.97, green: 0.96, blue: 0.91
    )

    private let interestOptions = [
        "Walking", "Fitness", "Cooking",
        "Gardening", "Reading", "Music",
        "Art", "Technology", "Travel",
        "Dancing", "Games", "Volunteering"
    ]

    private let skillOptions = [
        "Technology", "Cooking", "Languages",
        "Music", "Art", "Fitness",
        "Gardening", "Career Advice"
    ]

    private let goalOptions = [
        "Make Friends", "Stay Active",
        "Learn New Skills", "Share Knowledge",
        "Build Confidence", "Community Connection"
    ]

    private let availabilityOptions = [
        "Weekday Mornings",
        "Weekday Afternoons",
        "Weekday Evenings",
        "Weekends"
    ]

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // ORIGINAL FULL-SCREEN BACKGROUND
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

                    // FULL-WIDTH TRANSLUCENT TITLE
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Create an account")
                            .font(.system(
                                size: 36,
                                weight: .bold
                            ))

                        Text("How would you like to contribute?")
                            .font(.system(
                                size: 20,
                                weight: .bold
                            ))
                    }
                    .foregroundStyle(forestGreen)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                    .padding(.top, 35)

                    ScrollView {

                        VStack(
                            alignment: .leading,
                            spacing: 24
                        ) {

                            // ROLE SELECTION
                            VStack(spacing: 20) {

                                RoleSelectionCard(
                                    title: "Senior",
                                    description:
                                        "Stay active, social,\nand supported",
                                    isSelected:
                                        store.profile.role == "senior"
                                ) {
                                    store.profile.role = "senior"
                                    store.profile.participationRole = [
                                        "mentor"
                                    ]
                                }

                                RoleSelectionCard(
                                    title: "Youth / Mentee",
                                    description:
                                        "Make a difference,\nlearn, and grow",
                                    isSelected:
                                        store.profile.role == "youth"
                                ) {
                                    store.profile.role = "youth"
                                    store.profile.participationRole = [
                                        "volunteer", "mentee"
                                    ]
                                }
                            }
                            .padding(.top, 24)

                            // ACCOUNT DETAILS
                            sectionTitle("Your Details")

                            VStack(spacing: 12) {

                                inputField(
                                    "Full Name",
                                    text: $store.profile.name
                                )
                                .textContentType(.name)

                                inputField(
                                    "Age",
                                    text: $ageText
                                )
                                .keyboardType(.numberPad)

                                inputField(
                                    "Email Address",
                                    text: $email
                                )
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                                SecureField(
                                    "Password (8+ characters)",
                                    text: $password
                                )
                                .textContentType(.oneTimeCode)
                                .signupInputStyle(cream: cream)

                                SecureField(
                                    "Confirm Password",
                                    text: $confirmPassword
                                )
                                .textContentType(.oneTimeCode)
                                .signupInputStyle(cream: cream)

                                inputField(
                                    "City",
                                    text: $store.profile.location.city
                                )
                            }

                            // INTERESTS
                            sectionTitle("What Interests You?")

                            Text("Choose all that apply")
                                .font(.system(size: 14))
                                .foregroundStyle(cream)

                            selectionGrid(
                                interestOptions,
                                selected: store.profile.interests
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.interests
                                )
                            }

                            // SKILLS OFFERED
                            sectionTitle("Skills You Can Share")

                            selectionGrid(
                                skillOptions,
                                selected: store.profile.skillsOffered
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.skillsOffered
                                )
                            }

                            // SKILLS WANTED
                            sectionTitle("Skills You Want to Learn")

                            selectionGrid(
                                skillOptions,
                                selected: store.profile.skillsWanted
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.skillsWanted
                                )
                            }

                            // GOALS
                            sectionTitle("Your Goals")

                            selectionGrid(
                                goalOptions,
                                selected: store.profile.goals
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.goals
                                )
                            }

                            // ACTIVITY PREFERENCE
                            sectionTitle("Preferred Activity Level")

                            selectionGrid(
                                ["low", "moderate", "high"],
                                selected: [
                                    store.profile.activityPreference
                                ]
                            ) { value in
                                store.profile.activityPreference = value
                            }

                            // MEETING PREFERENCE
                            sectionTitle("How Would You Like to Meet?")

                            selectionGrid(
                                ["in-person", "virtual", "both"],
                                selected:
                                    store.profile.meetingPreference
                            ) { value in
                                store.profile.meetingPreference = [
                                    value
                                ]
                            }

                            // AVAILABILITY
                            sectionTitle("When Are You Available?")

                            selectionGrid(
                                availabilityOptions,
                                selected: store.profile.availability
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.availability
                                )
                            }

                            // ERROR MESSAGE
                            if let errorMessage {

                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(cream.opacity(0.95))
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                            }

                            // CREATE ACCOUNT BUTTON
                            Button {

                                Task {
                                    await createAccount()
                                }

                            } label: {

                                HStack(spacing: 10) {

                                    if isLoading {
                                        ProgressView()
                                            .tint(forestGreen)
                                    }

                                    Text(
                                        isLoading
                                            ? "Creating Account..."
                                            : "Create Account"
                                    )
                                    .font(.system(
                                        size: 18,
                                        weight: .semibold
                                    ))

                                    if !isLoading {
                                        Image(
                                            systemName: "arrow.right"
                                        )
                                    }
                                }
                                .foregroundStyle(forestGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(cream)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.7 : 1)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 28)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }

        // SUCCESS CONFIRMATION
        .alert(
            "Welcome to Kindred!",
            isPresented: $accountCreated
        ) {
            Button("Continue to Kindred") {
                showMainApp = true
            }
        } message: {
            Text(
                "Your account and matching profile have been saved."
            )
        }

        // ENTER MAIN APP AFTER SUCCESSFUL SIGNUP
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
                .interactiveDismissDisabled()
        }
    }

    // MARK: - UI HELPERS

    private func sectionTitle(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.system(
                size: 23,
                weight: .bold
            ))
            .foregroundStyle(forestGreen)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
    }

    private func inputField(
        _ placeholder: String,
        text: Binding<String>
    ) -> some View {

        TextField(placeholder, text: text)
            .signupInputStyle(cream: cream)
    }

    private func selectionGrid(
        _ options: [String],
        selected: [String],
        action: @escaping (String) -> Void
    ) -> some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 10
        ) {

            ForEach(options, id: \.self) { option in

                let isSelected = selected.contains(option)

                Button {
                    action(option)
                } label: {

                    HStack(spacing: 6) {

                        Text(option)
                            .font(.system(
                                size: 14,
                                weight: .medium
                            ))
                            .lineLimit(2)

                        Spacer(minLength: 0)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                        }
                    }
                    .foregroundStyle(cream)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(
                        forestGreen.opacity(
                            isSelected ? 0.95 : 0.80
                        )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected
                                    ? cream
                                    : cream.opacity(0.4),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(
        _ value: String,
        in array: inout [String]
    ) {

        if array.contains(value) {
            array.removeAll { $0 == value }
        } else {
            array.append(value)
        }
    }

    // MARK: - BACKEND REGISTRATION

    @MainActor
    private func createAccount() async {

        guard !isLoading else { return }

        errorMessage = nil

        let name = store.profile.name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !name.isEmpty,
              let age = Int(ageText),
              (13...120).contains(age),
              !cleanEmail.isEmpty,
              !store.profile.role.isEmpty else {

            errorMessage =
                "Please enter your name, valid age, email, and role."
            return
        }

        guard password.count >= 8 else {
            errorMessage =
                "Password must be at least 8 characters."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard !store.profile.interests.isEmpty,
              !store.profile.goals.isEmpty else {

            errorMessage =
                "Please select at least one interest and goal."
            return
        }

        store.profile.age = age

        isLoading = true
        defer { isLoading = false }

        do {

            // EXISTING MONGODB BACKEND CONNECTION
            try await AuthService.shared.register(
                name: name,
                email: cleanEmail,
                password: password,
                age: age,
                role: store.profile.role,
                profile: store.profile
            )

            // Registration and profile save succeeded.
            // AuthService must also save the JWT.
            password = ""
            confirmPassword = ""

            accountCreated = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - INPUT STYLE

private struct SignupInputModifier: ViewModifier {

    let cream: Color

    func body(content: Content) -> some View {

        content
            .font(.system(size: 16))
            .foregroundStyle(.black)
            .padding(16)
            .background(cream.opacity(0.95))
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
    }
}

private extension View {

    func signupInputStyle(
        cream: Color
    ) -> some View {

        modifier(SignupInputModifier(cream: cream))
    }
}

// MARK: - ROLE SELECTION CARD

struct RoleSelectionCard: View {

    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    private let forestGreen = Color(
        red: 0.12, green: 0.28, blue: 0.20
    )

    private let cream = Color(
        red: 0.97, green: 0.96, blue: 0.91
    )

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(title)
                        .font(.system(
                            size: 24,
                            weight: .semibold
                        ))

                    Text(description)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 24))
            }
            .foregroundStyle(cream)
            .padding(24)
            .frame(
                maxWidth: .infinity,
                minHeight: 155
            )
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        forestGreen.opacity(
                            isSelected ? 0.95 : 0.80
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isSelected
                            ? cream
                            : cream.opacity(0.65),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SignUpView(store: SignupStore())
    }
}
