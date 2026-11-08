
import SwiftUI

// MARK: - KINDRED TABS

enum KindredTab: Int, CaseIterable {

    case matches
    case activities
    case chats
    case profile

    var title: String {

        switch self {

        case .matches:
            return "Matches"

        case .activities:
            return "Activities"

        case .chats:
            return "Chats"

        case .profile:
            return "Profile"
        }
    }

    var icon: String {

        switch self {

        case .matches:
            return "person.2"

        case .activities:
            return "calendar"

        case .chats:
            return "message"

        case .profile:
            return "person.crop.circle"
        }
    }

    var selectedIcon: String {

        switch self {

        case .matches:
            return "person.2.fill"

        case .activities:
            return "calendar"

        case .chats:
            return "message.fill"

        case .profile:
            return "person.crop.circle.fill"
        }
    }
}

// MARK: - MAIN TAB VIEW

struct MainTabView: View {

    @State private var selectedTab: KindredTab = .matches

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

            // MARK: CURRENT SCREEN

            Group {

                switch selectedTab {

                case .matches:
                    MatchesView()

                case .activities:
                    ActivitiesView()

                case .chats:
                    ChatsView()

                case .profile:
                    ProfileView()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {

            bottomNavigationBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - BOTTOM NAVIGATION BAR

    private var bottomNavigationBar: some View {

        HStack(spacing: 0) {

            ForEach(KindredTab.allCases, id: \.self) { tab in

                Button {

                    withAnimation(.easeInOut(duration: 0.15)) {

                        selectedTab = tab
                    }

                } label: {

                    VStack(spacing: 6) {

                        Image(
                            systemName: selectedTab == tab
                                ? tab.selectedIcon
                                : tab.icon
                        )
                        .font(.system(size: 23))

                        Text(tab.title)
                            .font(
                                .system(
                                    size: 11,
                                    weight: selectedTab == tab
                                        ? .semibold
                                        : .medium
                                )
                            )
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
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(
                    selectedTab == tab ? .isSelected : []
                )
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
}

// MARK: - PREVIEW

#Preview {

    NavigationStack {

        MainTabView()
    }
}
