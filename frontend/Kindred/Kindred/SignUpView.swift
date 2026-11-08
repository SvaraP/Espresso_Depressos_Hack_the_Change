
import SwiftUI

// MARK: - SIGN UP VIEW

struct SignUpView: View {

    @Bindable var store: SignupStore

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var ageText = ""

    // Accessibility information
    @State private var accessibilityRequired: Bool?
    @State private var accessibilityNotes = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var accountCreated = false
    @State private var showProfile = false
    

    private let forestGreen = Color(
        red: 0.12,
        green: 0.28,
        blue: 0.20
    )

    private let cream = Color(
        red: 0.97,
        green: 0.96,
        blue: 0.91
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

    // MARK: - MAIN VIEW

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // Full-screen background
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

                    // Full-width translucent title
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

                            // MARK: ROLE SELECTION

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

                            // MARK: ACCOUNT DETAILS

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
                                .textContentType(.newPassword)
                                .signupInputStyle(cream: cream)

                                SecureField(
                                    "Confirm Password",
                                    text: $confirmPassword
                                )
                                .textContentType(.newPassword)
                                .signupInputStyle(cream: cream)

                                inputField(
                                    "City",
                                    text: $store.profile.location.city
                                )
                            }

                            // MARK: ACCESSIBILITY REQUIREMENTS

                            sectionTitle("Accessibility Requirements")

                            VStack(
                                alignment: .leading,
                                spacing: 14
                            ) {

                                Text(
                                    "Do you require accessibility accommodations?"
                                )
                                .font(.system(
                                    size: 16,
                                    weight: .semibold
                                ))
                                .foregroundStyle(forestGreen)

                                HStack(spacing: 12) {

                                    accessibilityOption(
                                        title: "Yes",
                                        isSelected:
                                            accessibilityRequired == true
                                    ) {
                                        accessibilityRequired = true
                                    }

                                    accessibilityOption(
                                        title: "No",
                                        isSelected:
                                            accessibilityRequired == false
                                    ) {
                                        accessibilityRequired = false
                                        accessibilityNotes = ""
                                    }
                                }

                                if accessibilityRequired == true {

                                    Text(
                                        "Accessibility Notes (Required)"
                                    )
                                    .font(.system(
                                        size: 15,
                                        weight: .semibold
                                    ))
                                    .foregroundStyle(forestGreen)

                                    TextEditor(
                                        text: $accessibilityNotes
                                    )
                                    .frame(minHeight: 110)
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .background(
                                        cream.opacity(0.95)
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )

                                    Text(
                                        "Please describe any accommodations you need, such as wheelchair access, accessible transportation, seating, or assistance with stairs."
                                    )
                                    .font(.system(size: 13))
                                    .foregroundStyle(
                                        forestGreen.opacity(0.75)
                                    )
                                }
                            }
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(.ultraThinMaterial)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                            )

                            // MARK: INTERESTS

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

                            // MARK: SKILLS OFFERED

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

                            // MARK: SKILLS WANTED

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

                            // MARK: GOALS

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

                            // MARK: ACTIVITY PREFERENCE

                            sectionTitle(
                                "Preferred Activity Level"
                            )

                            selectionGrid(
                                ["low", "moderate", "high"],
                                selected: [
                                    store.profile.activityPreference
                                ]
                            ) { value in
                                store.profile.activityPreference = value
                            }

                            // MARK: MEETING PREFERENCE

                            sectionTitle(
                                "How Would You Like to Meet?"
                            )

                            selectionGrid(
                                ["in-person", "virtual", "both"],
                                selected:
                                    store.profile.meetingPreference
                            ) { value in
                                store.profile.meetingPreference = [
                                    value
                                ]
                            }

                            // MARK: AVAILABILITY

                            sectionTitle(
                                "When Are You Available?"
                            )

                            selectionGrid(
                                availabilityOptions,
                                selected: store.profile.availability
                            ) { value in
                                toggle(
                                    value,
                                    in: &store.profile.availability
                                )
                            }

                            // MARK: ERROR MESSAGE

                            if let errorMessage {

                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        cream.opacity(0.95)
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                            }

                            // MARK: CREATE ACCOUNT

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
                                    RoundedRectangle(
                                        cornerRadius: 12
                                    )
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

        // MARK: SUCCESS CONFIRMATION

        .alert(
            "Welcome to Kindred!",
            isPresented: $accountCreated
        ) {
            Button("View My Profile") {
                showProfile = true
            }
        } message: {
            Text(
                "Your account and matching profile have been saved."
            )
        }

        .navigationDestination(
            isPresented: $showProfile
        ) {
            MainTabView()
                .navigationBarBackButtonHidden(true)
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

        TextField(
            placeholder,
            text: text
        )
        .signupInputStyle(cream: cream)
    }

    // MARK: - ACCESSIBILITY BUTTON

    private func accessibilityOption(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            HStack(spacing: 8) {

                Text(title)
                    .font(.system(
                        size: 16,
                        weight: .semibold
                    ))

                Spacer()

                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 18))
            }
            .foregroundStyle(cream)
            .padding(16)
            .frame(maxWidth: .infinity)
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

    // MARK: - SELECTION GRID

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

            ForEach(
                options,
                id: \.self
            ) { option in

                let isSelected =
                    selected.contains(option)

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

                            Image(
                                systemName: "checkmark"
                            )
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
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .stroke(
                            isSelected
                                ? cream
                                : cream.opacity(0.4),
                            lineWidth:
                                isSelected ? 2 : 1
                        )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - TOGGLE SELECTIONS

    private func toggle(
        _ value: String,
        in array: inout [String]
    ) {

        if array.contains(value) {
            array.removeAll {
                $0 == value
            }
        } else {
            array.append(value)
        }
    }

    // MARK: - BACKEND REGISTRATION

    @MainActor
    private func createAccount() async {

        guard !isLoading else {
            return
        }

        errorMessage = nil

        let name =
            store.profile.name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // Validate account information
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

            errorMessage =
                "Passwords do not match."
            return
        }

        guard !store.profile.interests.isEmpty,
              !store.profile.goals.isEmpty else {

            errorMessage =
                "Please select at least one interest and goal."
            return
        }

        // Validate accessibility requirements
        guard let accessibilityRequired else {

            errorMessage =
                "Please select Yes or No for accessibility requirements."
            return
        }

        let cleanNotes =
            accessibilityNotes.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if accessibilityRequired && cleanNotes.isEmpty {

            errorMessage =
                "Please provide accessibility notes."
            return
        }

        store.profile.age = age

        // Store accessibility information
        store.profile.accessibilityRequired =
            accessibilityRequired

        store.profile.accessibilityNotes =
            accessibilityRequired ? cleanNotes : ""

        isLoading = true

        defer {
            isLoading = false
        }

        do {

            try await AuthService.shared.register(
                name: name,
                email: cleanEmail,
                password: password,
                age: age,
                role: store.profile.role,
                profile: store.profile
            )

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

    func body(
        content: Content
    ) -> some View {

        content
            .font(.system(size: 16))
            .foregroundStyle(.black)
            .padding(16)
            .background(
                cream.opacity(0.95)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12
                )
            )
    }
}

private extension View {

    func signupInputStyle(
        cream: Color
    ) -> some View {

        modifier(
            SignupInputModifier(
                cream: cream
            )
        )
    }
}

// MARK: - ROLE SELECTION CARD

struct RoleSelectionCard: View {

    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    private let forestGreen = Color(
        red: 0.12,
        green: 0.28,
        blue: 0.20
    )

    private let cream = Color(
        red: 0.97,
        green: 0.96,
        blue: 0.91
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
                        .font(.system(
                            size: 16
                        ))
                        .multilineTextAlignment(
                            .leading
                        )
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
                RoundedRectangle(
                    cornerRadius: 22
                )
                .fill(
                    forestGreen.opacity(
                        isSelected ? 0.95 : 0.80
                    )
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 22
                )
                .stroke(
                    isSelected
                        ? cream
                        : cream.opacity(0.65),
                    lineWidth:
                        isSelected ? 2 : 1
                )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PREVIEW

#Preview {
    NavigationStack {
        SignUpView(
            store: SignupStore()
        )
    }
}

