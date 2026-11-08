
import SwiftUI

// MARK: - MATCH MODEL

struct KindredMatch: Identifiable {
    let id: String
    let name: String
    let age: Int?
    let role: String
    let city: String
    let interests: [String]
    let skillsOffered: [String]
    let skillsWanted: [String]
    let goals: [String]
    let activityPreference: String
    let meetingPreference: [String]
    let availability: [String]
    let score: Double?

    init?(json: [String: Any]) {
        let user =
            json["user"] as? [String: Any]
            ?? json["matchedUser"] as? [String: Any]
            ?? json["candidate"] as? [String: Any]
            ?? json

        guard let id =
            user["_id"] as? String
            ?? user["id"] as? String,
            !id.isEmpty
        else {
            return nil
        }

        self.id = id
        self.name = user["name"] as? String ?? "Kindred Member"
        self.age = user["age"] as? Int
        self.role = user["role"] as? String ?? ""
        self.interests = user["interests"] as? [String] ?? []
        self.skillsOffered = user["skillsOffered"] as? [String] ?? []
        self.skillsWanted = user["skillsWanted"] as? [String] ?? []
        self.goals = user["goals"] as? [String] ?? []

        self.activityPreference =
            user["activityPreference"] as? String ?? "moderate"

        if let preferences = user["meetingPreference"] as? [String] {
            self.meetingPreference = preferences
        } else if let preference = user["meetingPreference"] as? String {
            self.meetingPreference = [preference]
        } else {
            self.meetingPreference = []
        }

        self.availability = user["availability"] as? [String] ?? []

        let location = user["location"] as? [String: Any]
        self.city = location?["city"] as? String ?? ""

        let compatibility = json["compatibility"] as? [String: Any]

        self.score = (
            compatibility?["score"] as? NSNumber
            ?? json["score"] as? NSNumber
        )?.doubleValue
    }
}

// MARK: - API SERVICE

private enum MatchAPI {

    static let baseURL = "http://127.0.0.1:5000/api/v1"

    static func request(
        path: String,
        method: String = "GET",
        body: [String: String]? = nil
    ) async throws -> Data {

        guard let token = AuthService.shared.getSavedToken() else {
            throw MatchError.message(
                "Please log in to view your matches."
            )
        }

        guard let url = URL(string: baseURL + path) else {
            throw MatchError.message("Invalid API URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        if let body {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            request.httpBody = try JSONSerialization.data(
                withJSONObject: body
            )
        }

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let http = response as? HTTPURLResponse else {
            throw MatchError.message(
                "Unable to contact the server."
            )
        }

        guard (200...299).contains(http.statusCode) else {
            let json = try? JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]

            let message = json?["message"] as? String
                ?? "Request failed (\(http.statusCode))."

            throw MatchError.message(message)
        }

        return data
    }

    static func getMatches() async throws -> [KindredMatch] {

        let data = try await request(
            path: "/matches?page=1&limit=50"
        )

        let object = try JSONSerialization.jsonObject(
            with: data
        )

        if let array = object as? [[String: Any]] {
            return array.compactMap { KindredMatch(json: $0) }
        }

        guard let json = object as? [String: Any] else {
            throw MatchError.message(
                "Unexpected matches response."
            )
        }

        let dataObject = json["data"] as? [String: Any]

        let rawMatches =
            json["matches"] as? [[String: Any]]
            ?? json["results"] as? [[String: Any]]
            ?? json["users"] as? [[String: Any]]
            ?? dataObject?["matches"] as? [[String: Any]]
            ?? dataObject?["results"] as? [[String: Any]]
            ?? dataObject?["users"] as? [[String: Any]]
            ?? json["data"] as? [[String: Any]]

        guard let rawMatches else {
            throw MatchError.message(
                "The matches response format needs updating."
            )
        }

        return rawMatches.compactMap {
            KindredMatch(json: $0)
        }
    }

    static func swipe(
        userId: String,
        action: String
    ) async throws -> SwipeResult {

        let data = try await request(
            path: "/swipes",
            method: "POST",
            body: [
                "targetUserId": userId,
                "action": action
            ]
        )

        let json = try JSONSerialization.jsonObject(
            with: data
        ) as? [String: Any] ?? [:]

        let resultData = json["data"] as? [String: Any]

        return SwipeResult(
            connected:
                json["connected"] as? Bool
                ?? resultData?["connected"] as? Bool
                ?? false,
            message: json["message"] as? String ?? ""
        )
    }
}

private struct SwipeResult {
    let connected: Bool
    let message: String
}

private enum MatchError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

// MARK: - MATCHES VIEW

struct MatchesView: View {

    @State private var matches: [KindredMatch] = []
    @State private var isLoading = true
    @State private var isSwiping = false
    @State private var errorMessage: String?
    @State private var notification: String?
    @State private var selectedMatch: KindredMatch?
    @State private var dragOffset: CGSize = .zero

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

    private var currentMatch: KindredMatch? {
        matches.first
    }

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

                    // TITLE BAND
                    VStack(alignment: .leading, spacing: 5) {

                        Text("Discover Connections")
                            .font(
                                .system(
                                    size: 29,
                                    weight: .bold
                                )
                            )
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)

                        Text(
                            "Find someone who shares your interests."
                        )
                        .font(
                            .system(
                                size: 15,
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
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .padding(.top, 12)

                    if isLoading {

                        Spacer()

                        ProgressView(
                            "Finding your connections..."
                        )
                        .tint(forestGreen)
                        .padding(25)
                        .background(.regularMaterial)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18
                            )
                        )

                        Spacer()

                    } else if let errorMessage {

                        Spacer()

                        statusCard(
                            icon: "exclamationmark.triangle",
                            title: "Unable to Load Matches",
                            message: errorMessage
                        )

                        Button("Try Again") {
                            Task {
                                await loadMatches()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(forestGreen)
                        .padding(.top, 16)

                        Spacer()

                    } else if let match = currentMatch {

                        // AVAILABLE SPACE EXCLUDES TAB BAR
                        let cardHeight = min(
                            max(310, geometry.size.height * 0.58),
                            430
                        )

                        Spacer(minLength: 8)

                        matchCard(
                            match,
                            height: cardHeight
                        )
                        .offset(dragOffset)
                        .rotationEffect(
                            .degrees(
                                Double(dragOffset.width / 30)
                            )
                        )
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onChanged { value in
                                    guard !isSwiping else {
                                        return
                                    }

                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    guard !isSwiping else {
                                        return
                                    }

                                    if value.translation.width > 110 {
                                        performSwipe("connect")
                                    } else if value.translation.width < -110 {
                                        performSwipe("pass")
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                        .onTapGesture {
                            guard !isSwiping else {
                                return
                            }

                            selectedMatch = match
                        }
                        .padding(.horizontal, 28)

                        Spacer(minLength: 8)

                        // ACTION BUTTONS
                        HStack(spacing: 35) {

                            actionButton(
                                icon: "xmark",
                                label: "Pass",
                                color: .red
                            ) {
                                performSwipe("pass")
                            }

                            actionButton(
                                icon: "info",
                                label: "Details",
                                color: forestGreen
                            ) {
                                selectedMatch = match
                            }

                            actionButton(
                                icon: "heart.fill",
                                label: "Connect",
                                color: forestGreen
                            ) {
                                performSwipe("connect")
                            }
                        }
                        .disabled(isSwiping)
                        .padding(.bottom, 12)

                    } else {

                        Spacer()

                        statusCard(
                            icon: "heart.circle",
                            title: "You're All Caught Up!",
                            message:
                                "There are no more recommended connections right now."
                        )

                        Button("Refresh Matches") {
                            Task {
                                await loadMatches()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(forestGreen)
                        .padding(.top, 16)

                        Spacer()
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .task {
            await loadMatches()
        }
        .sheet(item: $selectedMatch) { match in
            MatchDetailView(match: match)
        }
        .alert(
            "Kindred",
            isPresented: Binding(
                get: { notification != nil },
                set: {
                    if !$0 {
                        notification = nil
                    }
                }
            )
        ) {
            Button("OK") {
                notification = nil
            }
        } message: {
            Text(notification ?? "")
        }
    }

    // MARK: - MATCH CARD

    private func matchCard(
        _ match: KindredMatch,
        height: CGFloat
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {

                Text("POTENTIAL CONNECTION")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.2)

                Spacer()

                Image(systemName: "heart")
                    .font(.system(size: 19))
            }

            Spacer(minLength: 2)

            // PROFILE AVATAR
            HStack {

                Spacer()

                ZStack {

                    Circle()
                        .fill(cream.opacity(0.16))
                        .frame(
                            width: 85,
                            height: 85
                        )

                    Image(
                        systemName: "person.crop.circle.fill"
                    )
                    .font(.system(size: 65))
                    .foregroundStyle(cream)
                }

                Spacer()
            }

            VStack(spacing: 5) {

                Text(
                    match.age.map {
                        "\(match.name), \($0)"
                    } ?? match.name
                )
                .font(
                    .system(
                        size: 23,
                        weight: .bold
                    )
                )
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .multilineTextAlignment(.center)

                if !match.city.isEmpty {

                    Label(
                        match.city,
                        systemImage: "mappin"
                    )
                    .font(.system(size: 13))
                }

                Text(
                    match.role == "senior"
                        ? "Senior"
                        : match.role == "youth"
                            ? "Youth / Mentee"
                            : "Kindred Member"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .medium
                    )
                )
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 2)

            if !match.interests.isEmpty {

                Text("Interests")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )

                FlowInterestView(
                    values: Array(
                        match.interests.prefix(4)
                    )
                )
            }

            if let score = match.score {

                let percentage = score <= 1
                    ? score * 100
                    : score

                Label(
                    "\(Int(percentage.rounded()))% compatibility",
                    systemImage: "sparkles"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
            }

            Divider()
                .overlay(cream.opacity(0.5))

            HStack(spacing: 6) {

                Image(
                    systemName: "hand.point.up.left"
                )

                Text("Tap for details")

                Spacer()

                Image(systemName: "arrow.left")
                Text("Pass")

                Image(systemName: "arrow.right")
                Text("Connect")
            }
            .font(.system(size: 9))
            .lineLimit(1)
        }
        .foregroundStyle(cream)
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background {
            RoundedRectangle(cornerRadius: 23)
                .fill(forestGreen.opacity(0.94))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 23)
                .stroke(
                    cream.opacity(0.75),
                    lineWidth: 1.5
                )
        }
        .shadow(
            color: .black.opacity(0.18),
            radius: 10,
            y: 5
        )
        .contentShape(
            RoundedRectangle(cornerRadius: 23)
        )
    }

    // MARK: - ACTION BUTTONS

    private func actionButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            VStack(spacing: 5) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )
                    .background(cream)
                    .clipShape(Circle())

                Text(label)
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
            }
            .foregroundStyle(color)
        }
        .buttonStyle(.plain)
    }

    // MARK: - STATUS CARD

    private func statusCard(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 15) {

            Image(systemName: icon)
                .font(.system(size: 42))

            Text(title)
                .font(
                    .system(
                        size: 23,
                        weight: .bold
                    )
                )

            Text(message)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(cream)
        .frame(maxWidth: .infinity)
        .padding(28)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(forestGreen.opacity(0.94))
        }
        .padding(.horizontal, 28)
    }

    // MARK: - LOAD MATCHES

    @MainActor
    private func loadMatches() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            matches = try await MatchAPI.getMatches()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - SWIPE HANDLING

    @MainActor
    private func performSwipe(_ action: String) {

        guard !isSwiping,
              let match = currentMatch else {
            return
        }

        isSwiping = true

        Task {

            do {

                let result = try await MatchAPI.swipe(
                    userId: match.id,
                    action: action
                )

                // ANIMATE AFTER BACKEND SUCCESS
                withAnimation(
                    .easeIn(duration: 0.22)
                ) {
                    dragOffset = CGSize(
                        width: action == "connect"
                            ? 600
                            : -600,
                        height: 0
                    )
                }

                try? await Task.sleep(
                    for: .milliseconds(240)
                )

                if !matches.isEmpty {
                    matches.removeFirst()
                }

                dragOffset = .zero
                isSwiping = false

                if result.connected {

                    notification =
                        "It's a match! You can now chat with \(match.name)."

                } else if action == "connect" {

                    notification =
                        "Connection interest sent to \(match.name). You'll connect when they also choose you."
                }

            } catch {

                withAnimation(.spring()) {
                    dragOffset = .zero
                }

                isSwiping = false
                notification = error.localizedDescription
            }
        }
    }
}

// MARK: - INTEREST TAGS

private struct FlowInterestView: View {

    let values: [String]

    var body: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 6
        ) {

            ForEach(values, id: \.self) { value in

                Text(value)
                    .font(
                        .system(
                            size: 11,
                            weight: .medium
                        )
                    )
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 5)
                    .background(
                        Color.white.opacity(0.15)
                    )
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - FULL MATCH PROFILE

private struct MatchDetailView: View {

    let match: KindredMatch

    @Environment(\.dismiss) private var dismiss

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

        NavigationStack {

            ZStack {

                Image("WelcomeBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 18) {

                        VStack(spacing: 12) {

                            Image(
                                systemName: "person.crop.circle.fill"
                            )
                            .font(.system(size: 80))

                            Text(match.name)
                                .font(
                                    .system(
                                        size: 28,
                                        weight: .bold
                                    )
                                )

                            if let age = match.age {
                                Text("\(age) years old")
                            }

                            if !match.city.isEmpty {

                                Label(
                                    match.city,
                                    systemImage: "mappin"
                                )
                            }

                            Text(
                                match.role == "senior"
                                    ? "Senior"
                                    : "Youth / Mentee"
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(forestGreen)
                        .foregroundStyle(cream)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 22
                            )
                        )

                        detailSection(
                            "Interests",
                            values: match.interests
                        )

                        detailSection(
                            "Skills They Can Share",
                            values: match.skillsOffered
                        )

                        detailSection(
                            "Skills They Want to Learn",
                            values: match.skillsWanted
                        )

                        detailSection(
                            "Goals",
                            values: match.goals
                        )

                        detailSection(
                            "Availability",
                            values: match.availability
                        )

                        detailSection(
                            "Activity Preference",
                            values: [
                                match.activityPreference
                            ]
                        )

                        detailSection(
                            "Meeting Preference",
                            values: match.meetingPreference
                        )
                    }
                    .padding(22)
                }
            }
            .navigationTitle(
                "About \(match.name)"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(forestGreen)
                }
            }
        }
    }

    // MARK: - DETAIL SECTIONS

    private func detailSection(
        _ title: String,
        values: [String]
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(title)
                .font(
                    .system(
                        size: 19,
                        weight: .bold
                    )
                )

            if values.isEmpty {

                Text("Not provided")
                    .font(.system(size: 14))
                    .opacity(0.75)

            } else {

                ForEach(values, id: \.self) { value in

                    Label(
                        value,
                        systemImage: "checkmark.circle"
                    )
                    .font(.system(size: 15))
                }
            }
        }
        .foregroundStyle(cream)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(forestGreen.opacity(0.94))
        }
    }
}

// MARK: - PREVIEW

#Preview {
    MatchesView()
}
