
import SwiftUI

// MARK: - PROFILE DATA

struct KindredProfile: Codable {
    var name: String
    var email: String?
    var age: Int?
    var role: String?
    var participationRoles: [String]?
    var interests: [String]?
    var skillsOffered: [String]?
    var skillsWanted: [String]?
    var goals: [String]?
    var activityPreference: String?
    var meetingPreference: String?
    var availability: [String]?
    var location: UserLocation?
}

private struct ProfileResponse: Decodable {
    let user: KindredProfile?
    let data: KindredProfile?
}

private struct ProfileUpdate: Encodable {
    let name: String
    let interests: [String]
    let skillsOffered: [String]
    let skillsWanted: [String]
    let goals: [String]
    let activityPreference: String
    let meetingPreference: String
    let availability: [String]
    let location: UserLocation
}

// MARK: - PROFILE VIEW

struct ProfileView: View {

    @State private var profile: KindredProfile?
    @State private var isEditing = false
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

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

                // SAME BACKGROUND AS SIGN UP
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

                        Text("My Profile")
                            .font(.system(
                                size: 36,
                                weight: .bold
                            ))

                        Text("Your Kindred community")
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
                    .padding(.vertical, 12)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                    .padding(.top, 35)

                    ScrollView {

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {

                            if isLoading {

                                loadingCard

                            } else if profile == nil {

                                errorCard

                            } else if let profile {

                                // USER INFORMATION
                                userCard(profile)

                                // STATUS MESSAGES
                                if let successMessage {
                                    messageCard(
                                        successMessage,
                                        isError: false
                                    )
                                }

                                if let errorMessage {
                                    messageCard(
                                        errorMessage,
                                        isError: true
                                    )
                                }

                                // EDIT BUTTON
                                editButton

                                // EDIT NAME AND CITY
                                if isEditing {
                                    editDetailsCard
                                }

                                // INTERESTS
                                profileSection(
                                    "My Interests",
                                    values: profile.interests ?? [],
                                    options: interestOptions
                                ) { value in
                                    toggle(
                                        value,
                                        keyPath: \.interests
                                    )
                                }

                                // SKILLS OFFERED
                                profileSection(
                                    "Skills I Can Share",
                                    values: profile.skillsOffered ?? [],
                                    options: skillOptions
                                ) { value in
                                    toggle(
                                        value,
                                        keyPath: \.skillsOffered
                                    )
                                }

                                // SKILLS WANTED
                                profileSection(
                                    "Skills I Want to Learn",
                                    values: profile.skillsWanted ?? [],
                                    options: skillOptions
                                ) { value in
                                    toggle(
                                        value,
                                        keyPath: \.skillsWanted
                                    )
                                }

                                // GOALS
                                profileSection(
                                    "My Goals",
                                    values: profile.goals ?? [],
                                    options: goalOptions
                                ) { value in
                                    toggle(
                                        value,
                                        keyPath: \.goals
                                    )
                                }

                                // ACTIVITY LEVEL
                                profileSection(
                                    "Preferred Activity Level",
                                    values: [
                                        profile.activityPreference
                                            ?? "moderate"
                                    ],
                                    options: [
                                        "low", "moderate", "high"
                                    ]
                                ) { value in
                                    self.profile?
                                        .activityPreference = value
                                }

                                // MEETING PREFERENCE
                                profileSection(
                                    "How I Like to Meet",
                                    values: [
                                        profile.meetingPreference
                                            ?? "both"
                                    ],
                                    options: [
                                        "in-person", "virtual", "both"
                                    ]
                                ) { value in
                                    self.profile?
                                        .meetingPreference = value
                                }

                                // AVAILABILITY
                                profileSection(
                                    "My Availability",
                                    values: profile.availability ?? [],
                                    options: availabilityOptions
                                ) { value in
                                    toggle(
                                        value,
                                        keyPath: \.availability
                                    )
                                }

                                // CANCEL EDITING
                                if isEditing {

                                    Button {
                                        isEditing = false

                                        Task {
                                            await loadProfile()
                                        }

                                    } label: {

                                        Text("Cancel Editing")
                                            .font(.system(
                                                size: 17,
                                                weight: .semibold
                                            ))
                                            .foregroundStyle(cream)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 52)
                                            .background(
                                                forestGreen.opacity(0.85)
                                            )
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 12
                                                )
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .task {
            await loadProfile()
        }
    }

    // MARK: - LOADING CARD

    private var loadingCard: some View {

        HStack(spacing: 12) {

            ProgressView()
                .tint(forestGreen)

            Text("Loading your profile...")
                .foregroundStyle(forestGreen)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - ERROR CARD

    private var errorCard: some View {

        VStack(alignment: .leading, spacing: 15) {

            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 35))
                .foregroundStyle(forestGreen)

            Text(errorMessage ?? "Unable to load profile.")
                .font(.system(size: 16))
                .foregroundStyle(forestGreen)

            Button {
                Task {
                    await loadProfile()
                }
            } label: {

                Text("Try Again")
                    .font(.system(
                        size: 16,
                        weight: .semibold
                    ))
                    .foregroundStyle(cream)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(forestGreen)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - USER CARD

    private func userCard(
        _ profile: KindredProfile
    ) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 16) {

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 65))
                    .foregroundStyle(cream)

                VStack(alignment: .leading, spacing: 6) {

                    Text(profile.name)
                        .font(.system(
                            size: 27,
                            weight: .bold
                        ))

                    Text(
                        profile.role == "senior"
                            ? "Senior"
                            : "Youth / Mentee"
                    )
                    .font(.system(size: 17))
                }

                Spacer()
            }

            Rectangle()
                .fill(cream.opacity(0.35))
                .frame(height: 1)

            if let age = profile.age {
                Label(
                    "Age \(age)",
                    systemImage: "person"
                )
            }

            if let city = profile.location?.city,
               !city.isEmpty {

                Label(
                    city,
                    systemImage: "mappin.and.ellipse"
                )
            }

            if let email = profile.email {

                Label(
                    email,
                    systemImage: "envelope"
                )
                .font(.system(size: 14))
                .lineLimit(2)
            }

            if let roles = profile.participationRoles,
               !roles.isEmpty {

                Text(
                    roles.map { $0.capitalized }
                        .joined(separator: " • ")
                )
                .font(.system(size: 14))
            }
        }
        .foregroundStyle(cream)
        .padding(24)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(forestGreen.opacity(0.90))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    cream.opacity(0.65),
                    lineWidth: 1
                )
        }
    }

    // MARK: - EDIT BUTTON

    private var editButton: some View {

        Button {

            if isEditing {

                Task {
                    await saveProfile()
                }

            } else {

                successMessage = nil
                isEditing = true
            }

        } label: {

            HStack(spacing: 10) {

                if isSaving {
                    ProgressView()
                        .tint(forestGreen)
                }

                Text(
                    isSaving
                        ? "Saving..."
                        : isEditing
                            ? "Save Changes"
                            : "Edit Profile"
                )

                if !isSaving {
                    Image(
                        systemName: isEditing
                            ? "checkmark"
                            : "pencil"
                    )
                }
            }
            .font(.system(
                size: 18,
                weight: .semibold
            ))
            .foregroundStyle(forestGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(cream)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(isSaving)
    }

    // MARK: - EDIT DETAILS

    private var editDetailsCard: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Edit Your Details")
                .font(.system(
                    size: 22,
                    weight: .bold
                ))
                .foregroundStyle(forestGreen)

            TextField(
                "Full Name",
                text: Binding(
                    get: {
                        profile?.name ?? ""
                    },
                    set: { value in
                        profile?.name = value
                    }
                )
            )
            .profileInputStyle(cream: cream)

            TextField(
                "City",
                text: Binding(
                    get: {
                        profile?.location?.city ?? ""
                    },
                    set: { value in
                        if profile?.location == nil {
                            profile?.location = UserLocation()
                        }
                        profile?.location?.city = value
                    }
                )
            )
            .profileInputStyle(cream: cream)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - PROFILE SECTIONS

    private func profileSection(
        _ title: String,
        values: [String],
        options: [String],
        action: @escaping (String) -> Void
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.system(
                    size: 22,
                    weight: .bold
                ))
                .foregroundStyle(forestGreen)

            let displayedValues = isEditing
                ? options
                : values

            if displayedValues.isEmpty {

                Text("Nothing added yet")
                    .font(.system(size: 15))
                    .foregroundStyle(forestGreen.opacity(0.7))

            } else {

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 10
                ) {

                    ForEach(
                        displayedValues,
                        id: \.self
                    ) { value in

                        let selected = values.contains(value)

                        Button {

                            if isEditing {
                                action(value)
                            }

                        } label: {

                            HStack(spacing: 8) {

                                Text(value)
                                    .font(.system(
                                        size: 14,
                                        weight: .medium
                                    ))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer(minLength: 0)

                                if isEditing && selected {

                                    Image(
                                        systemName: "checkmark"
                                    )
                                    .font(.system(size: 13))
                                }
                            }
                            .foregroundStyle(cream)
                            .padding(.horizontal, 12)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 50
                            )
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                                .fill(
                                    forestGreen.opacity(
                                        selected ? 0.95 : 0.80
                                    )
                                )
                            }
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                                .stroke(
                                    selected
                                        ? cream
                                        : cream.opacity(0.65),
                                    lineWidth: selected ? 2 : 1
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(!isEditing)
                    }
                }
            }
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - STATUS MESSAGE

    private func messageCard(
        _ message: String,
        isError: Bool
    ) -> some View {

        Text(message)
            .font(.system(size: 15))
            .foregroundStyle(
                isError ? Color.red : forestGreen
            )
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
    }

    // MARK: - TOGGLE SELECTIONS

    private func toggle(
        _ value: String,
        keyPath: WritableKeyPath<KindredProfile, [String]?>
    ) {

        guard var currentProfile = profile else {
            return
        }

        var values = currentProfile[keyPath: keyPath] ?? []

        if values.contains(value) {
            values.removeAll { $0 == value }
        } else {
            values.append(value)
        }

        currentProfile[keyPath: keyPath] = values
        profile = currentProfile
    }

    // MARK: - AUTHENTICATED REQUEST

    private func authenticatedRequest(
        method: String
    ) throws -> URLRequest {

        guard let token =
            AuthService.shared.getSavedToken() else {

            throw AuthError.serverError(
                "Please log in to view your profile."
            )
        }

        let url = URL(
            string: "http://127.0.0.1:5000/api/v1/users/me"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        return request
    }

    // MARK: - LOAD PROFILE FROM MONGODB

    @MainActor
    private func loadProfile() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            let request = try authenticatedRequest(
                method: "GET"
            )

            let (data, response) =
                try await URLSession.shared.data(
                    for: request
                )

            guard let http =
                response as? HTTPURLResponse,
                (200...299).contains(http.statusCode) else {

                throw AuthError.serverError(
                    "Unable to load your profile."
                )
            }

            let decoder = JSONDecoder()

            // Direct user response
            if let direct = try? decoder.decode(
                KindredProfile.self,
                from: data
            ) {
                profile = direct
                return
            }

            // Wrapped response
            let wrapped = try decoder.decode(
                ProfileResponse.self,
                from: data
            )

            guard let savedProfile =
                wrapped.user ?? wrapped.data else {

                throw AuthError.invalidResponse
            }

            profile = savedProfile

        } catch {

            errorMessage = error.localizedDescription
        }
    }

    // MARK: - SAVE PROFILE TO MONGODB

    @MainActor
    private func saveProfile() async {

        guard let profile else {
            return
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        defer {
            isSaving = false
        }

        do {

            var request = try authenticatedRequest(
                method: "PUT"
            )

            let update = ProfileUpdate(
                name: profile.name,
                interests: profile.interests ?? [],
                skillsOffered: profile.skillsOffered ?? [],
                skillsWanted: profile.skillsWanted ?? [],
                goals: profile.goals ?? [],
                activityPreference:
                    profile.activityPreference ?? "moderate",
                meetingPreference:
                    profile.meetingPreference ?? "both",
                availability: profile.availability ?? [],
                location: profile.location ?? UserLocation()
            )

            request.httpBody = try JSONEncoder().encode(
                update
            )

            let (data, response) =
                try await URLSession.shared.data(
                    for: request
                )

            guard let http =
                response as? HTTPURLResponse,
                (200...299).contains(http.statusCode) else {

                throw AuthError.serverError(
                    String(
                        data: data,
                        encoding: .utf8
                    ) ?? "Unable to save changes."
                )
            }

            isEditing = false

            await loadProfile()

            if errorMessage == nil {
                successMessage =
                    "Your profile has been updated successfully!"
            }

        } catch {

            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - INPUT STYLING

private struct ProfileInputModifier: ViewModifier {

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

    func profileInputStyle(
        cream: Color
    ) -> some View {

        modifier(
            ProfileInputModifier(cream: cream)
        )
    }
}

// MARK: - PREVIEW

#Preview {
    NavigationStack {
        ProfileView()
    }
}
