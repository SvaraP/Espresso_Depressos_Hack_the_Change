
import SwiftUI

// MARK: - THEME

private enum ActivityStyle {
    static let green = Color(
        red: 0.12, green: 0.28, blue: 0.20
    )

    static let cream = Color(
        red: 0.97, green: 0.96, blue: 0.91
    )
}

// MARK: - MODELS

private struct BackendActivity: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let category: String
    let intensity: String
    let description: String
    let equipment: [String]
    let setting: String
    let adaptable: Bool?
    let seated: Bool?
    let wheelchairFriendly: Bool?
    let accessibilityTags: [String]
    let source: String?

    var id: String { slug }

    var icon: String {
        let value = (slug + " " + category).lowercased()

        if value.contains("walk") { return "figure.walk" }
        if value.contains("swim") { return "water.waves" }
        if value.contains("cycl") { return "bicycle" }
        if value.contains("yoga") { return "figure.mind.and.body" }
        if value.contains("garden") { return "leaf.fill" }
        if value.contains("danc") { return "music.note" }
        if value.contains("bowl") { return "figure.bowling" }

        return "figure.cooldown"
    }

    var categoryLabel: String {
        category.replacingOccurrences(
            of: "-",
            with: " "
        ).capitalized
    }

    var settingLabel: String {
        setting.replacingOccurrences(
            of: "-",
            with: " "
        ).capitalized
    }
}

private struct ActivityConnection: Identifiable, Hashable {
    let id: String
    let name: String
}

private struct IntensityPreference: Decodable {
    let userA: String
    let userB: String
    let shared: String
}

private struct RecommendationsResponse: Decodable {
    let success: Bool
    let recommendations: [BackendActivity]
    let intensityPreference: IntensityPreference
    let disclaimer: String?
}

// MARK: - API CLIENT

private enum ActivityAPI {

    // Use the same base URL as ChatsView.
    static let baseURL = "http://127.0.0.1:5000/api/v1"

    static func get(_ path: String) async throws -> Data {

        guard let token =
            AuthService.shared.getSavedToken() else {
            throw APIError.message("Please log in again.")
        }

        guard let url = URL(string: baseURL + path) else {
            throw APIError.message("Invalid API URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await URLSession.shared.data(for: request)

        guard let http =
            response as? HTTPURLResponse else {
            throw APIError.message("Invalid server response.")
        }

        guard (200...299).contains(http.statusCode) else {

            let body = try? JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]

            let message = body?["message"] as? String
                ?? "Request failed."

            throw APIError.message(
                "\(message) (HTTP \(http.statusCode))"
            )
        }

        return data
    }

    static func getConnections() async throws
        -> [ActivityConnection] {

        let data = try await get("/connections")

        guard let json =
            try JSONSerialization.jsonObject(with: data)
                as? [String: Any] else {
            throw APIError.message(
                "Unexpected connections response."
            )
        }

        // Support common connection response envelopes.
        let records: [[String: Any]]

        if let array = json["connections"] as? [[String: Any]] {
            records = array
        } else if let array = json["data"] as? [[String: Any]] {
            records = array
        } else if let dataObject = json["data"] as? [String: Any],
                  let array = dataObject["connections"]
                    as? [[String: Any]] {
            records = array
        } else {
            throw APIError.message(
                "Could not find connections in API response."
            )
        }

        print("Connections returned by backend: \(records.count)")

        let connections = records.compactMap { item
            -> ActivityConnection? in

            if let status = item["status"] as? String,
               status.lowercased() != "active" {
                return nil
            }

            let id = (
                item["connectionId"] as? String
                ?? item["_id"] as? String
                ?? item["id"] as? String
            )

            guard let id, !id.isEmpty else {
                return nil
            }

            // Supports a response with an already-resolved
            // other-user object.
            let person = (
                item["user"] as? [String: Any]
                ?? item["otherUser"] as? [String: Any]
                ?? item["connectedUser"] as? [String: Any]
                ?? item["matchedUser"] as? [String: Any]
            )

            let name = person?["name"] as? String
                ?? "Connection"

            return ActivityConnection(id: id, name: name)
        }

        if !records.isEmpty && connections.isEmpty {
            throw APIError.message(
                "Connections were returned, but their IDs or statuses could not be parsed."
            )
        }

        return connections
    }

    static func getActivities(
        connectionId: String
    ) async throws -> RecommendationsResponse {

        let data = try await get(
            "/connections/\(connectionId)/activities"
        )

        return try JSONDecoder().decode(
            RecommendationsResponse.self,
            from: data
        )
    }
}

private enum APIError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let text):
            return text
        }
    }
}

// MARK: - INTEREST STORE

@MainActor
private final class ActivityInterestStore: ObservableObject {

    @Published private(set) var activities:
        [BackendActivity] = []

    private let key = "kindred.interested.activities.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(
                [BackendActivity].self,
                from: data
           ) {
            activities = saved
        }
    }

    func contains(_ activity: BackendActivity) -> Bool {
        activities.contains { $0.slug == activity.slug }
    }

    func toggle(_ activity: BackendActivity) {

        if contains(activity) {
            activities.removeAll {
                $0.slug == activity.slug
            }
        } else {
            activities.append(activity)
        }

        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - MAIN VIEW

struct ActivitiesView: View {

    @StateObject private var interests =
        ActivityInterestStore()

    @State private var selectedTab = 0
    @State private var searchText = ""

    @State private var connections: [ActivityConnection] = []
    @State private var selectedConnectionId = ""

    @State private var recommendations: [BackendActivity] = []
    @State private var sharedIntensity = ""

    @State private var loading = false
    @State private var errorMessage: String?
    @State private var hasLoaded = false

    @State private var selectedActivity: BackendActivity?

    private var displayedActivities: [BackendActivity] {

        let source = selectedTab == 0
            ? recommendations
            : interests.activities

        guard !searchText.isEmpty else {
            return source
        }

        return source.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.category.localizedCaseInsensitiveContains(searchText)
            || $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {

        NavigationStack {

            GeometryReader { geometry in

                ZStack {

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

                        header

                        tabs
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        searchBar
                            .padding(.horizontal, 24)
                            .padding(.top, 14)

                        ScrollView {

                            LazyVStack(spacing: 14) {

                                if selectedTab == 0 {
                                    suggestedHeader
                                } else {
                                    myActivitiesHeader
                                }

                                ForEach(displayedActivities) { activity in
                                    activityCard(activity)
                                }

                                if selectedTab == 1
                                    && displayedActivities.isEmpty {

                                    messageCard(
                                        icon: "heart",
                                        title: "No Saved Activities",
                                        message:
                                            "Tap I'm Interested on a suggested activity to save it here."
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            if selectedTab == 0 {
                                await loadConnections()
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedActivity) {
                activity in

                ActivityDetailsView(
                    activity: activity,
                    interests: interests
                )
            }
            .task {
                if !hasLoaded {
                    hasLoaded = true
                    await loadConnections()
                }
            }
        }
    }

    // MARK: - HEADER

    private var header: some View {

        VStack(alignment: .leading, spacing: 7) {

            Text("Activities")
                .font(.system(size: 35, weight: .bold))

            Text("Discover something together.")
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundStyle(ActivityStyle.green)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 28)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial)
        .padding(.top, 12)
    }

    // MARK: - TABS

    private var tabs: some View {

        HStack(spacing: 10) {

            tabButton("Suggested", index: 0)
            tabButton("My Activities", index: 1)
        }
    }

    private func tabButton(
        _ title: String,
        index: Int
    ) -> some View {

        Button {

            withAnimation {
                selectedTab = index
                searchText = ""
            }

        } label: {

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    selectedTab == index
                        ? ActivityStyle.cream
                        : ActivityStyle.green
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    selectedTab == index
                        ? ActivityStyle.green
                        : ActivityStyle.cream
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - SEARCH

    private var searchBar: some View {

        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")

            TextField(
                "Search activities",
                text: $searchText
            )
        }
        .foregroundStyle(ActivityStyle.green)
        .padding(15)
        .background(ActivityStyle.cream)
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }

    // MARK: - SUGGESTED HEADER

    @ViewBuilder
    private var suggestedHeader: some View {

        if loading {

            ProgressView("Loading recommendations...")
                .tint(ActivityStyle.green)
                .padding(24)

        } else if let errorMessage {

            messageCard(
                icon: "exclamationmark.triangle",
                title: "Unable to Load Activities",
                message: errorMessage
            )

            Button("Try Again") {
                Task {
                    await loadConnections()
                }
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(ActivityStyle.cream)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(ActivityStyle.green)
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )

        } else if connections.isEmpty {

            messageCard(
                icon: "person.2",
                title: "No Active Connections",
                message:
                    "Activity recommendations are generated for connected Kindred members. Once you have an active connection, recommendations will appear here."
            )

        } else {

            if connections.count > 1 {

                HStack {

                    Text("Activities with")
                        .font(.system(size: 13))

                    Spacer()

                    Picker(
                        "Connection",
                        selection: $selectedConnectionId
                    ) {

                        ForEach(connections) { connection in

                            Text(connection.name)
                                .tag(connection.id)
                        }
                    }
                    .tint(ActivityStyle.green)
                }
                .foregroundStyle(ActivityStyle.green)
                .padding(12)
                .background(ActivityStyle.cream)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
                .onChange(of: selectedConnectionId) { _, id in

                    Task {
                        await loadRecommendations(for: id)
                    }
                }
            }

            HStack {

                VStack(alignment: .leading, spacing: 5) {

                    Text("Recommended for You")
                        .font(
                            .system(
                                size: 19,
                                weight: .bold
                            )
                        )

                    Text("Personalized by Kindred")
                        .font(.system(size: 12))
                }

                Spacer()

                Text("\(displayedActivities.count)")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(ActivityStyle.green)

            if !sharedIntensity.isEmpty {

                Label(
                    "Shared activity level: \(sharedIntensity.capitalized)",
                    systemImage: "figure.walk"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(ActivityStyle.green)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(13)
                .background(ActivityStyle.cream)
                .clipShape(
                    RoundedRectangle(cornerRadius: 13)
                )
            }

            if recommendations.isEmpty {

                messageCard(
                    icon: "sparkles",
                    title: "No Recommendations",
                    message:
                        "The backend did not return any activities for this connection."
                )
            }
        }
    }

    // MARK: - MY ACTIVITIES HEADER

    private var myActivitiesHeader: some View {

        HStack {

            Text("Activities I'm Interested In")
                .font(.system(size: 18, weight: .bold))

            Spacer()

            Text("\(displayedActivities.count) saved")
                .font(.system(size: 12))
        }
        .foregroundStyle(ActivityStyle.green)
    }

    // MARK: - ACTIVITY CARD

    private func activityCard(
        _ activity: BackendActivity
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            HStack(alignment: .top, spacing: 14) {

                Image(systemName: activity.icon)
                    .font(.system(size: 27))
                    .foregroundStyle(ActivityStyle.green)
                    .frame(width: 58, height: 58)
                    .background(ActivityStyle.cream)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )

                VStack(alignment: .leading, spacing: 6) {

                    Text(activity.name)
                        .font(
                            .system(
                                size: 18,
                                weight: .bold
                            )
                        )

                    Text(activity.categoryLabel)
                        .font(.system(size: 12))

                    Text(
                        "\(activity.intensity.capitalized) Intensity"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
                }

                Spacer()

                Button {

                    withAnimation {
                        interests.toggle(activity)
                    }

                } label: {

                    Image(
                        systemName: interests.contains(activity)
                            ? "heart.fill"
                            : "heart"
                    )
                    .font(.system(size: 24))
                    .foregroundStyle(ActivityStyle.cream)
                }
                .buttonStyle(.plain)
            }

            Text(activity.description)
                .font(.system(size: 13))
                .lineLimit(3)

            HStack {

                Label(
                    activity.settingLabel,
                    systemImage: "mappin.and.ellipse"
                )

                Spacer()

                if activity.adaptable == true {

                    Label(
                        "Adaptable",
                        systemImage: "checkmark.circle"
                    )
                }
            }
            .font(.system(size: 11))

            HStack(spacing: 10) {

                Button {

                    selectedActivity = activity

                } label: {

                    HStack {

                        Text("View Details")

                        Spacer()

                        Image(systemName: "arrow.right")
                    }
                    .font(
                        .system(
                            size: 13,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(ActivityStyle.green)
                    .padding(13)
                    .background(ActivityStyle.cream)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }

                Button {

                    withAnimation {
                        interests.toggle(activity)
                    }

                } label: {

                    Text(
                        interests.contains(activity)
                            ? "Interested ✓"
                            : "I'm Interested"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(ActivityStyle.green)
                    .padding(13)
                    .background(ActivityStyle.cream)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(ActivityStyle.cream)
        .padding(17)
        .background(ActivityStyle.green.opacity(0.96))
        .clipShape(
            RoundedRectangle(cornerRadius: 21)
        )
    }

    // MARK: - MESSAGE CARD

    private func messageCard(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 13) {

            Image(systemName: icon)
                .font(.system(size: 34))

            Text(title)
                .font(
                    .system(
                        size: 19,
                        weight: .bold
                    )
                )

            Text(message)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(ActivityStyle.cream)
        .frame(maxWidth: .infinity)
        .padding(25)
        .background(ActivityStyle.green)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - BACKEND LOADING

    @MainActor
    private func loadConnections() async {

        loading = true
        errorMessage = nil
        recommendations = []
        sharedIntensity = ""

        do {

            let result = try await
                ActivityAPI.getConnections()

            connections = result

            guard !result.isEmpty else {
                loading = false
                return
            }

            let id: String

            if result.contains(
                where: { $0.id == selectedConnectionId }
            ) {
                id = selectedConnectionId
            } else {
                id = result[0].id
            }

            selectedConnectionId = id

            await loadRecommendations(for: id)

        } catch {

            connections = []
            errorMessage = error.localizedDescription
            loading = false

            print(
                "Kindred connections API error:",
                error.localizedDescription
            )
        }
    }

    @MainActor
    private func loadRecommendations(
        for connectionId: String
    ) async {

        guard !connectionId.isEmpty else {
            return
        }

        loading = true
        errorMessage = nil
        recommendations = []
        sharedIntensity = ""

        do {

            let result = try await
                ActivityAPI.getActivities(
                    connectionId: connectionId
                )

            recommendations = result.recommendations
            sharedIntensity =
                result.intensityPreference.shared

            print(
                "Loaded \(recommendations.count) backend activities"
            )

            print(
                "Shared intensity: \(sharedIntensity)"
            )

        } catch {

            errorMessage = error.localizedDescription

            print(
                "Kindred recommendations API error:",
                error.localizedDescription
            )
        }

        loading = false
    }
}

// MARK: - DETAILS VIEW

private struct ActivityDetailsView: View {

    let activity: BackendActivity

    @ObservedObject var interests: ActivityInterestStore

    var body: some View {

        ZStack {

            ActivityStyle.cream
                .ignoresSafeArea()

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {

                    VStack(spacing: 15) {

                        Image(systemName: activity.icon)
                            .font(.system(size: 50))

                        Text(activity.name)
                            .font(
                                .system(
                                    size: 28,
                                    weight: .bold
                                )
                            )

                        Text(
                            "\(activity.intensity.capitalized) Intensity"
                        )
                        .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .foregroundStyle(ActivityStyle.cream)
                    .background(ActivityStyle.green)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )

                    Text("About")
                        .font(
                            .system(
                                size: 21,
                                weight: .bold
                            )
                        )

                    Text(activity.description)

                    Divider()

                    Label(
                        activity.settingLabel,
                        systemImage: "mappin.and.ellipse"
                    )

                    if activity.adaptable == true {
                        Label(
                            "Adaptable",
                            systemImage: "checkmark.circle"
                        )
                    }

                    if activity.seated == true {
                        Label(
                            "Seated participation",
                            systemImage: "chair"
                        )
                    }

                    if activity.wheelchairFriendly == true {
                        Label(
                            "Wheelchair friendly",
                            systemImage: "figure.roll"
                        )
                    }

                    if !activity.equipment.isEmpty {

                        Text("Equipment")
                            .font(
                                .system(
                                    size: 21,
                                    weight: .bold
                                )
                            )

                        ForEach(activity.equipment, id: \.self) {
                            item in

                            Text("• \(item.capitalized)")
                        }
                    }

                    Text(
                        "Activity preferences are not a medical assessment. Choose activities appropriate to your abilities."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                    Button {

                        interests.toggle(activity)

                    } label: {

                        Label(
                            interests.contains(activity)
                                ? "Remove from My Activities"
                                : "I'm Interested",
                            systemImage:
                                interests.contains(activity)
                                    ? "heart.fill"
                                    : "heart"
                        )
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(ActivityStyle.cream)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(ActivityStyle.green)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 15)
                        )
                    }
                }
                .foregroundStyle(ActivityStyle.green)
                .padding(24)
            }
        }
        .navigationTitle("Activity Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

#Preview {
    ActivitiesView()
}

