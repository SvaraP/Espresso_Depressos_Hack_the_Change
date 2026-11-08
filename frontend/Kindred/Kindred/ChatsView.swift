
import SwiftUI

// MARK: - THEME

private enum KindredChatsTheme {

    static let green = Color(
        red: 0.12,
        green: 0.28,
        blue: 0.20
    )

    static let cream = Color(
        red: 0.97,
        green: 0.96,
        blue: 0.91
    )
}

// MARK: - MODELS

private struct KindredChatPerson: Identifiable, Hashable {

    let id: String
    let name: String
    let age: Int?
    let city: String

    init(
        id: String,
        name: String,
        age: Int? = nil,
        city: String = ""
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.city = city
    }

    init?(json: [String: Any]) {

        guard let id = json["_id"] as? String
                ?? json["id"] as? String else {
            return nil
        }

        self.id = id
        self.name = json["name"] as? String
            ?? "Kindred Member"
        self.age = json["age"] as? Int

        if let location = json["location"] as? [String: Any] {
            self.city = location["city"] as? String ?? ""
        } else {
            self.city = json["location"] as? String ?? ""
        }
    }
}

private struct KindredChatThread: Identifiable, Hashable {

    let id: String
    let person: KindredChatPerson
    let isDemo: Bool
    let preview: String

    static func == (
        lhs: KindredChatThread,
        rhs: KindredChatThread
    ) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private struct KindredChatMessage: Identifiable {

    let id: String
    let text: String
    let isMine: Bool

    init(
        id: String = UUID().uuidString,
        text: String,
        isMine: Bool
    ) {
        self.id = id
        self.text = text
        self.isMine = isMine
    }
}

private struct KindredChatRequest: Identifiable {

    let id: String
    let person: KindredChatPerson
    let status: RequestStatus
}

private enum RequestStatus: String, CaseIterable {

    case all = "All"
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"

    var icon: String {
        switch self {
        case .all:
            return "line.3.horizontal.decrease"
        case .pending:
            return "clock"
        case .accepted:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }
}

// MARK: - DEMO CONTENT

private enum KindredDemoData {

    static let margaret = KindredChatPerson(
        id: "demo-margaret",
        name: "Margaret Wilson",
        age: 68,
        city: "Calgary"
    )

    static let robert = KindredChatPerson(
        id: "demo-robert",
        name: "Robert Thompson",
        age: 72,
        city: "Calgary"
    )

    static let eleanor = KindredChatPerson(
        id: "demo-eleanor",
        name: "Eleanor Brooks",
        age: 76,
        city: "Calgary"
    )

    static let harpreet = KindredChatPerson(
        id: "demo-harpreet",
        name: "Harpreet Singh",
        age: 65,
        city: "Calgary"
    )

    static let threads: [KindredChatThread] = [

        KindredChatThread(
            id: margaret.id,
            person: margaret,
            isDemo: true,
            preview:
                "I really enjoy walking around Prince's Island Park!"
        ),

        KindredChatThread(
            id: robert.id,
            person: robert,
            isDemo: true,
            preview:
                "I'd love some help learning to use my phone."
        ),

        KindredChatThread(
            id: eleanor.id,
            person: eleanor,
            isDemo: true,
            preview:
                "Perhaps we could visit a local art gallery!"
        )
    ]

    static let requests: [KindredChatRequest] = [

        KindredChatRequest(
            id: "request-margaret",
            person: margaret,
            status: .accepted
        ),

        KindredChatRequest(
            id: "request-robert",
            person: robert,
            status: .accepted
        ),

        KindredChatRequest(
            id: "request-harpreet",
            person: harpreet,
            status: .pending
        ),

        KindredChatRequest(
            id: "request-eleanor",
            person: eleanor,
            status: .rejected
        )
    ]

    static let messages: [String: [KindredChatMessage]] = [

        margaret.id: [

            KindredChatMessage(
                text:
                    "Hello! I noticed we both enjoy spending time outdoors.",
                isMine: false
            ),

            KindredChatMessage(
                text:
                    "Hi Margaret! I love hiking and exploring Calgary.",
                isMine: true
            ),

            KindredChatMessage(
                text:
                    "That's wonderful! I've been wanting to find a walking buddy.",
                isMine: false
            ),

            KindredChatMessage(
                text:
                    "I'd love that! Do you have a favourite place?",
                isMine: true
            ),

            KindredChatMessage(
                text:
                    "I really enjoy walking around Prince's Island Park!",
                isMine: false
            )
        ],

        robert.id: [

            KindredChatMessage(
                text:
                    "Hello! I'm Robert. It's nice to meet you.",
                isMine: false
            ),

            KindredChatMessage(
                text:
                    "Hi Robert! What would you like to learn together?",
                isMine: true
            ),

            KindredChatMessage(
                text:
                    "I'd love some help learning to use my phone.",
                isMine: false
            )
        ],

        eleanor.id: [

            KindredChatMessage(
                text:
                    "Hello! I heard you enjoy art and creative activities.",
                isMine: false
            ),

            KindredChatMessage(
                text:
                    "I do! I love discovering new creative hobbies.",
                isMine: true
            ),

            KindredChatMessage(
                text:
                    "Perhaps we could visit a local art gallery!",
                isMine: false
            )
        ]
    ]

    static func reply(
        for personId: String,
        message: String
    ) -> String {

        let lower = message.lowercased()

        if lower.contains("hello") || lower.contains("hi") {
            return "Hello! It's so lovely to hear from you!"
        }

        if lower.contains("when")
            || lower.contains("weekend")
            || lower.contains("available") {
            return "I'm usually free on weekends. Would Saturday work for you?"
        }

        if lower.contains("where")
            || lower.contains("park")
            || lower.contains("walk") {
            return "Prince's Island Park sounds wonderful! We could meet there."
        }

        if lower.contains("coffee") {
            return "Coffee sounds lovely! I'd really enjoy that."
        }

        if lower.contains("thank") {
            return "You're very welcome! I'm happy we connected."
        }

        switch personId {

        case margaret.id:
            return [
                "That sounds wonderful! I'd love to do that together.",
                "It's so nice having someone to share these experiences with.",
                "I think a walk and a good conversation would be lovely."
            ].randomElement()!

        case robert.id:
            return [
                "Thank you! Technology feels much less intimidating with a little help.",
                "That sounds like a great idea. I'm excited to learn!",
                "I appreciate you taking the time to help me."
            ].randomElement()!

        case eleanor.id:
            return [
                "What a lovely idea! I've always enjoyed creative activities.",
                "I'd really enjoy spending an afternoon together.",
                "It's wonderful meeting someone with similar interests."
            ].randomElement()!

        default:
            return "That sounds wonderful! I'd love to hear more."
        }
    }
}

// MARK: - REAL BACKEND SERVICE

private enum KindredChatsAPI {

    static let baseURL =
        "http://127.0.0.1:5000/api/v1"

    static func request(
        _ path: String,
        method: String = "GET",
        body: [String: String]? = nil
    ) async throws -> [String: Any] {

        guard let token =
            AuthService.shared.getSavedToken() else {
            throw NSError(
                domain: "KindredChats",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Please log in."
                ]
            )
        }

        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
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

        let (data, response) =
            try await URLSession.shared.data(for: request)

        guard let http =
            response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {

            let errorJSON =
                try? JSONSerialization.jsonObject(
                    with: data
                ) as? [String: Any]

            throw NSError(
                domain: "KindredChats",
                code: http.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        errorJSON?["message"] as? String
                        ?? "Server error (\(http.statusCode))."
                ]
            )
        }

        return try JSONSerialization.jsonObject(
            with: data
        ) as? [String: Any] ?? [:]
    }

    static func loadConnections() async throws
        -> [KindredChatPerson] {

        let json = try await request("/connections")

        let connections = json["connections"]
            as? [[String: Any]] ?? []

        return connections.compactMap { connection in

            guard let user =
                connection["user"] as? [String: Any] else {
                return nil
            }

            return KindredChatPerson(json: user)
        }
    }

    static func loadConversations() async throws
        -> [KindredChatThread] {

        let json = try await request("/chats")

        let conversations = json["conversations"]
            as? [[String: Any]] ?? []

        return conversations.compactMap { item in

            guard let id =
                item["conversationId"] as? String,
                let user =
                    item["user"] as? [String: Any],
                let person =
                    KindredChatPerson(json: user) else {
                return nil
            }

            return KindredChatThread(
                id: id,
                person: person,
                isDemo: false,
                preview: item["lastMessage"] as? String
                    ?? "Start a conversation"
            )
        }
    }

    static func createConversation(
        with userId: String
    ) async throws -> String {

        let json = try await request(
            "/chats/conversation",
            method: "POST",
            body: ["targetUserId": userId]
        )

        guard let conversation =
            json["conversation"] as? [String: Any],
            let id = conversation["_id"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return id
    }

    static func loadCurrentUserId() async throws -> String {

        let json = try await request("/users/me")

        guard let user =
            json["user"] as? [String: Any],
            let id = user["id"] as? String
                ?? user["_id"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return id
    }

    static func loadMessages(
        conversationId: String,
        currentUserId: String
    ) async throws -> [KindredChatMessage] {

        let json = try await request(
            "/chats/\(conversationId)/messages"
        )

        let messages = json["messages"]
            as? [[String: Any]] ?? []

        return messages.compactMap { item in

            guard let id = item["_id"] as? String,
                  let text = item["text"] as? String else {
                return nil
            }

            let senderId: String

            if let sender =
                item["sender"] as? [String: Any] {
                senderId = sender["_id"] as? String ?? ""
            } else {
                senderId = item["sender"] as? String ?? ""
            }

            return KindredChatMessage(
                id: id,
                text: text,
                isMine: senderId == currentUserId
            )
        }
    }

    static func sendMessage(
        conversationId: String,
        text: String
    ) async throws {

        _ = try await request(
            "/chats/message",
            method: "POST",
            body: [
                "conversationId": conversationId,
                "text": text
            ]
        )
    }
}

// MARK: - SHARED DEMO MESSAGE STORE

@MainActor
private final class KindredDemoChatStore: ObservableObject {

    @Published var messages =
        KindredDemoData.messages

    func messagesFor(
        _ personId: String
    ) -> [KindredChatMessage] {

        messages[personId] ?? []
    }

    func append(
        _ message: KindredChatMessage,
        to personId: String
    ) {

        messages[personId, default: []].append(message)
    }

    func preview(
        for personId: String
    ) -> String {

        messages[personId]?.last?.text ?? ""
    }
}

// MARK: - MAIN CHATS VIEW

struct ChatsView: View {

    @StateObject private var demoStore =
        KindredDemoChatStore()

    @State private var selectedSection = 0
    @State private var selectedFilter: RequestStatus = .all
    @State private var searchText = ""

    @State private var realThreads: [KindredChatThread] = []
    @State private var realConnections: [KindredChatPerson] = []

    @State private var selectedThread: KindredChatThread?
    @State private var isLoading = false
    @State private var openingUserId: String?
    @State private var backendNotice: String?

    private var allThreads: [KindredChatThread] {

        let realPersonIds = Set(
            realThreads.map { $0.person.id }
        )

        let demoThreads = KindredDemoData.threads.filter {
            !realPersonIds.contains($0.person.id)
        }

        return realThreads + demoThreads
    }

    private var filteredThreads: [KindredChatThread] {

        allThreads.filter { thread in

            searchText.isEmpty
            || thread.person.name
                .localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredRequests: [KindredChatRequest] {

        KindredDemoData.requests.filter { request in

            let matchesSearch =
                searchText.isEmpty
                || request.person.name
                    .localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedFilter == .all
                || request.status == selectedFilter

            return matchesSearch && matchesStatus
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

                        HStack(spacing: 10) {

                            sectionButton(
                                "Active Chats",
                                index: 0
                            )

                            sectionButton(
                                "Requests",
                                index: 1
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        searchBar

                        if selectedSection == 1 {
                            requestFilters
                        }

                        ScrollView {

                            LazyVStack(spacing: 12) {

                                if selectedSection == 0 {

                                    activeChatsContent

                                } else {

                                    requestsContent
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                            .padding(.bottom, 24)
                        }
                        .refreshable {
                            await loadRealData()
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(
                item: $selectedThread
            ) { thread in

                KindredChatDetailView(
                    thread: thread,
                    demoStore: demoStore
                )
            }
            .task {
                await loadRealData()
            }
        }
    }

    // MARK: - HEADER

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Your Connections")
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )

            Text("Conversations that bring us together.")
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
        }
        .foregroundStyle(KindredChatsTheme.green)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 28)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial)
        .padding(.top, 12)
    }

    // MARK: - SECTION BUTTON

    private func sectionButton(
        _ title: String,
        index: Int
    ) -> some View {

        Button {

            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSection = index
            }

        } label: {

            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    selectedSection == index
                        ? KindredChatsTheme.cream
                        : KindredChatsTheme.green
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    selectedSection == index
                        ? KindredChatsTheme.green
                        : KindredChatsTheme.cream
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - SEARCH

    private var searchBar: some View {

        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")

            TextField(
                "Search connections",
                text: $searchText
            )
            .autocorrectionDisabled()
        }
        .foregroundStyle(KindredChatsTheme.green)
        .padding(14)
        .background(KindredChatsTheme.cream)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .padding(.horizontal, 24)
        .padding(.top, 14)
    }

    // MARK: - FILTERS

    private var requestFilters: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: 8) {

                ForEach(
                    RequestStatus.allCases,
                    id: \.self
                ) { filter in

                    Button {
                        selectedFilter = filter
                    } label: {

                        Text(filter.rawValue)
                            .font(
                                .system(
                                    size: 13,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(
                                selectedFilter == filter
                                    ? KindredChatsTheme.cream
                                    : KindredChatsTheme.green
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                selectedFilter == filter
                                    ? KindredChatsTheme.green
                                    : KindredChatsTheme.cream
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 14)
    }

    // MARK: - ACTIVE CHATS

    @ViewBuilder
    private var activeChatsContent: some View {

        if let backendNotice {

            HStack(spacing: 8) {

                Image(systemName: "info.circle")

                Text(backendNotice)
                    .font(.system(size: 12))
            }
            .foregroundStyle(KindredChatsTheme.green)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }

        if isLoading && allThreads.isEmpty {

            ProgressView("Loading conversations...")
                .tint(KindredChatsTheme.green)
                .padding(25)

        } else if filteredThreads.isEmpty
                    && realConnections.isEmpty {

            emptyCard(
                icon: "bubble.left.and.bubble.right",
                title: "No Conversations",
                message: "Try searching for another member."
            )

        } else {

            ForEach(filteredThreads) { thread in

                Button {
                    selectedThread = thread
                } label: {

                    chatRow(thread)
                }
                .buttonStyle(.plain)
            }

            // Real active connections without a conversation yet
            ForEach(realConnections.filter { person in

                !realThreads.contains {
                    $0.person.id == person.id
                }
                && (
                    searchText.isEmpty
                    || person.name
                        .localizedCaseInsensitiveContains(
                            searchText
                        )
                )

            }) { person in

                Button {

                    Task {
                        await openRealConnection(person)
                    }

                } label: {

                    HStack(spacing: 14) {

                        avatar

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text(person.name)
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .bold
                                    )
                                )

                            Text("Tap to start chatting")
                                .font(.system(size: 13))
                                .opacity(0.8)
                        }

                        Spacer()

                        if openingUserId == person.id {

                            ProgressView()
                                .tint(KindredChatsTheme.cream)

                        } else {

                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundStyle(KindredChatsTheme.cream)
                    .padding(16)
                    .background(
                        KindredChatsTheme.green.opacity(0.95)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                }
                .buttonStyle(.plain)
                .disabled(openingUserId != nil)
            }
        }
    }

    // MARK: - CHAT ROW

    private func chatRow(
        _ thread: KindredChatThread
    ) -> some View {

        HStack(spacing: 14) {

            avatar

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                HStack(spacing: 7) {

                    Text(thread.person.name)
                        .font(
                            .system(
                                size: 17,
                                weight: .bold
                            )
                        )

                    if thread.isDemo {

                        Text("DEMO")
                            .font(
                                .system(
                                    size: 9,
                                    weight: .bold
                                )
                            )
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(
                                KindredChatsTheme.cream.opacity(0.2)
                            )
                            .clipShape(Capsule())
                    }
                }

                Text(
                    thread.isDemo
                        ? demoStore.preview(for: thread.person.id)
                        : thread.preview
                )
                .font(.system(size: 13))
                .lineLimit(2)
                .opacity(0.85)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
        }
        .foregroundStyle(KindredChatsTheme.cream)
        .padding(16)
        .background(
            KindredChatsTheme.green.opacity(0.95)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - REQUESTS

    @ViewBuilder
    private var requestsContent: some View {

        HStack(spacing: 8) {

            Image(systemName: "info.circle.fill")

            Text(
                "Demo requests — statuses are simulated."
            )
            .font(.system(size: 12))
        }
        .foregroundStyle(KindredChatsTheme.green)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )

        if filteredRequests.isEmpty {

            emptyCard(
                icon: "heart",
                title: "No Requests Found",
                message: "No requests match your search or filter."
            )

        } else {

            ForEach(filteredRequests) { request in

                HStack(spacing: 12) {

                    avatar

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(request.person.name)
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold
                                )
                            )

                        Text(request.person.city)
                            .font(.system(size: 12))
                            .opacity(0.8)
                    }

                    Spacer(minLength: 4)

                    Label(
                        request.status.rawValue,
                        systemImage: request.status.icon
                    )
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(KindredChatsTheme.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(KindredChatsTheme.cream)
                    .clipShape(Capsule())
                }
                .foregroundStyle(KindredChatsTheme.cream)
                .padding(15)
                .background(
                    KindredChatsTheme.green.opacity(0.95)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
            }
        }
    }

    // MARK: - SHARED COMPONENTS

    private var avatar: some View {

        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 46))
            .foregroundStyle(KindredChatsTheme.cream)
            .frame(width: 50, height: 50)
    }

    private func emptyCard(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 14) {

            Image(systemName: icon)
                .font(.system(size: 40))

            Text(title)
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )

            Text(message)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(KindredChatsTheme.cream)
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            KindredChatsTheme.green.opacity(0.95)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }

    // MARK: - LOAD REAL DATA

    @MainActor
    private func loadRealData() async {

        guard !isLoading else { return }

        isLoading = true
        backendNotice = nil

        do {

            async let connections =
                KindredChatsAPI.loadConnections()

            async let conversations =
                KindredChatsAPI.loadConversations()

            realConnections = try await connections
            realThreads = try await conversations

        } catch {

            // Keep the demo functional if the backend is unavailable.
            backendNotice =
                "Showing demo conversations. Live connections are temporarily unavailable."
        }

        isLoading = false
    }

    // MARK: - OPEN REAL CONNECTION

    @MainActor
    private func openRealConnection(
        _ person: KindredChatPerson
    ) async {

        guard openingUserId == nil else { return }

        openingUserId = person.id

        defer {
            openingUserId = nil
        }

        do {

            let id = try await
                KindredChatsAPI.createConversation(
                    with: person.id
                )

            let thread = KindredChatThread(
                id: id,
                person: person,
                isDemo: false,
                preview: "Start a conversation"
            )

            realThreads.append(thread)
            selectedThread = thread

        } catch {

            backendNotice = error.localizedDescription
        }
    }
}

// MARK: - CHAT DETAIL VIEW

private struct KindredChatDetailView: View {

    let thread: KindredChatThread

    @ObservedObject var demoStore: KindredDemoChatStore

    @State private var realMessages: [KindredChatMessage] = []
    @State private var currentUserId = ""
    @State private var messageText = ""

    @State private var isSending = false
    @State private var isTyping = false
    @State private var errorMessage: String?

    private var displayedMessages: [KindredChatMessage] {

        if thread.isDemo {
            return demoStore.messagesFor(thread.person.id)
        }

        return realMessages
    }

    var body: some View {

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

                    chatHeader

                    ScrollViewReader { proxy in

                        ScrollView {

                            LazyVStack(spacing: 12) {

                                if let errorMessage {

                                    Text(errorMessage)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.red)
                                        .padding(12)
                                        .background(.regularMaterial)
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )
                                }

                                ForEach(displayedMessages) { message in

                                    messageBubble(message)
                                        .id(message.id)
                                }

                                if isTyping {

                                    HStack {

                                        HStack(spacing: 7) {

                                            ProgressView()
                                                .tint(
                                                    KindredChatsTheme.green
                                                )

                                            Text(
                                                "\(thread.person.name.components(separatedBy: " ").first ?? "Member") is typing..."
                                            )
                                            .font(.system(size: 13))
                                        }
                                        .foregroundStyle(
                                            KindredChatsTheme.green
                                        )
                                        .padding(13)
                                        .background(
                                            KindredChatsTheme.cream
                                        )
                                        .clipShape(Capsule())

                                        Spacer()
                                    }
                                }

                                if displayedMessages.isEmpty {

                                    Text(
                                        "Say hello to \(thread.person.name)!"
                                    )
                                    .font(.system(size: 14))
                                    .foregroundStyle(
                                        KindredChatsTheme.green
                                    )
                                    .padding(16)
                                    .background(.regularMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(18)
                        }
                        .onChange(of: displayedMessages.count) { _, _ in

                            if let last = displayedMessages.last {

                                withAnimation {

                                    proxy.scrollTo(
                                        last.id,
                                        anchor: .bottom
                                    )
                                }
                            }
                        }
                        .refreshable {

                            if !thread.isDemo {
                                await loadRealMessages()
                            }
                        }
                    }

                    messageComposer
                }
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task {

            if !thread.isDemo {
                await initializeRealChat()
            }
        }
    }

    // MARK: - HEADER

    private var chatHeader: some View {

        HStack(spacing: 12) {

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 40))

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(thread.person.name)
                    .font(
                        .system(
                            size: 19,
                            weight: .bold
                        )
                    )

                Text(
                    thread.isDemo
                        ? "Demo Conversation"
                        : "Kindred Connection"
                )
                .font(.system(size: 12))
            }

            Spacer()

            if thread.isDemo {

                Text("DEMO")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        KindredChatsTheme.green.opacity(0.12)
                    )
                    .clipShape(Capsule())
            }
        }
        .foregroundStyle(KindredChatsTheme.green)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - MESSAGE BUBBLE

    private func messageBubble(
        _ message: KindredChatMessage
    ) -> some View {

        HStack {

            if message.isMine {
                Spacer(minLength: 55)
            }

            Text(message.text)
                .font(.system(size: 15))
                .foregroundStyle(
                    message.isMine
                        ? KindredChatsTheme.cream
                        : KindredChatsTheme.green
                )
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(
                    message.isMine
                        ? KindredChatsTheme.green
                        : KindredChatsTheme.cream
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

            if !message.isMine {
                Spacer(minLength: 55)
            }
        }
    }

    // MARK: - MESSAGE COMPOSER

    private var messageComposer: some View {

        HStack(spacing: 10) {

            TextField(
                "Write a message...",
                text: $messageText,
                axis: .vertical
            )
            .lineLimit(1...4)
            .padding(13)
            .background(KindredChatsTheme.cream)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )

            Button {

                Task {
                    await sendMessage()
                }

            } label: {

                if isSending {

                    ProgressView()
                        .tint(KindredChatsTheme.cream)
                        .frame(width: 44, height: 44)

                } else {

                    Image(systemName: "arrow.up")
                        .font(
                            .system(
                                size: 18,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(KindredChatsTheme.cream)
                        .frame(width: 44, height: 44)
                }
            }
            .background(KindredChatsTheme.green)
            .clipShape(Circle())
            .disabled(
                isSending
                || messageText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding(14)
        .background(.ultraThinMaterial)
    }

    // MARK: - INITIALIZE REAL CHAT

    @MainActor
    private func initializeRealChat() async {

        do {

            currentUserId = try await
                KindredChatsAPI.loadCurrentUserId()

            await loadRealMessages()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - LOAD REAL MESSAGES

    @MainActor
    private func loadRealMessages() async {

        do {

            realMessages = try await
                KindredChatsAPI.loadMessages(
                    conversationId: thread.id,
                    currentUserId: currentUserId
                )

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - SEND MESSAGE

    @MainActor
    private func sendMessage() async {

        let text = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !text.isEmpty, !isSending else {
            return
        }

        isSending = true

        defer {
            isSending = false
        }

        if thread.isDemo {

            // Local demo message
            demoStore.append(
                KindredChatMessage(
                    text: text,
                    isMine: true
                ),
                to: thread.person.id
            )

            messageText = ""
            isTyping = true

            // Simulated response
            try? await Task.sleep(
                for: .milliseconds(1200)
            )

            let reply = KindredDemoData.reply(
                for: thread.person.id,
                message: text
            )

            demoStore.append(
                KindredChatMessage(
                    text: reply,
                    isMine: false
                ),
                to: thread.person.id
            )

            isTyping = false

        } else {

            // Real MongoDB message
            do {

                try await KindredChatsAPI.sendMessage(
                    conversationId: thread.id,
                    text: text
                )

                messageText = ""
                await loadRealMessages()

            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - PREVIEW

#Preview {
    ChatsView()
}

