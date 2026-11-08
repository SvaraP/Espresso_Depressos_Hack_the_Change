
import SwiftUI

enum KindredTab: Int, CaseIterable {
    case home
    case matches
    case activities
    case chats
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .matches: return "Matches"
        case .activities: return "Activities"
        case .chats: return "Chats"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .matches: return "person.2"
        case .activities: return "calendar"
        case .chats: return "message"
        case .profile: return "person.crop.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .matches: return "person.2.fill"
        case .activities: return "calendar"
        case .chats: return "message.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {

    @State private var selectedTab: KindredTab = .home

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

        ZStack {

            // CURRENT SCREEN
            Group {
                switch selectedTab {

                case .home:
                    placeholderPage(
                        title: "Home",
                        subtitle: "Your Kindred dashboard",
                        icon: "house.fill"
                    )

                case .matches:
                    MatchesView()

                case .activities:
                    placeholderPage(
                        title: "Activities",
                        subtitle: "Discover something together",
                        icon: "calendar"
                    )

                case .chats:
                    placeholderPage(
                        title: "Chats",
                        subtitle: "Connect with your matches",
                        icon: "message.fill"
                    )

                case .profile:
                    ProfileView()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomNavigationBar
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - BOTTOM NAVIGATION BAR

    private var bottomNavigationBar: some View {

        HStack(spacing: 0) {

            ForEach(KindredTab.allCases, id: \.self) { tab in

                Button {
                    selectedTab = tab
                } label: {

                    VStack(spacing: 6) {

                        Image(
                            systemName: selectedTab == tab
                                ? tab.selectedIcon
                                : tab.icon
                        )
                        .font(.system(size: 23))

                        Text(tab.title)
                            .font(.system(
                                size: 11,
                                weight: selectedTab == tab
                                    ? .semibold
                                    : .medium
                            ))
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? forestGreen
                            : forestGreen.opacity(0.55)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(forestGreen.opacity(0.15))
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - TEMPORARY PAGES

    private func placeholderPage(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {

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

                    VStack(alignment: .leading, spacing: 8) {

                        Text(title)
                            .font(.system(
                                size: 36,
                                weight: .bold
                            ))

                        Text(subtitle)
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
                    .background(.ultraThinMaterial)
                    .padding(.top, 35)

                    Spacer()

                    VStack(spacing: 18) {

                        Image(systemName: icon)
                            .font(.system(size: 50))

                        Text(title)
                            .font(.system(
                                size: 25,
                                weight: .bold
                            ))

                        Text("Coming soon")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(cream)
                    .frame(maxWidth: .infinity)
                    .padding(35)
                    .background {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(forestGreen.opacity(0.9))
                    }
                    .padding(.horizontal, 28)

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
