
import SwiftUI

struct SignUpView: View {

    @Bindable var store: SignupStore

    let forestGreen = Color(red: 0.12, green: 0.28, blue: 0.20)
    let cream = Color(red: 0.97, green: 0.96, blue: 0.91)

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // FULL-SCREEN BACKGROUND IMAGE
                Image("WelcomeBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .ignoresSafeArea()

                // MAIN VERTICAL LAYOUT
                VStack(spacing: 0) {

                    // TRANSLUCENT TITLE SECTION
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Create an account")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(forestGreen)

                        Text("How would you like to contribute?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(forestGreen)
                    }
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

                    // ROLE SELECTION CARDS
                    VStack(spacing: 20) {

                        // SENIOR CARD
                        RoleSelectionCard(
                            title: "Senior",
                            description: "Stay active, social,\nand supported",
                            isSelected: store.profile.role == "senior"
                        ) {
                            store.profile.role = "senior"
                            store.profile.participationRole = []
                        }

                        // YOUTH / VOLUNTEER CARD
                        RoleSelectionCard(
                            title: "Youth / Mentee",
                            description: "Make a difference,\nlearn, and grow",
                            isSelected: store.profile.role == "youth"
                        ) {
                            store.profile.role = "youth"
                            store.profile.participationRole = ["volunteer"]
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 110)

                    // PUSH CONTINUE BUTTON DOWN
                    Spacer(minLength: 20)

                    // CONTINUE BUTTON
                    Button {
                        print("Selected role:", store.profile.role)
                        print(
                            "Participation:",
                            store.profile.participationRole
                        )
                    } label: {

                        HStack(spacing: 10) {

                            Text("Continue")
                                .font(.system(
                                    size: 18,
                                    weight: .semibold
                                ))

                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(forestGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(cream)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .disabled(store.profile.role.isEmpty)
                    .opacity(
                        store.profile.role.isEmpty ? 0.75 : 1
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 30)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .background {
            Image("WelcomeBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
}


// REUSABLE ROLE SELECTION CARD
struct RoleSelectionCard: View {

    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    let forestGreen = Color(red: 0.12, green: 0.28, blue: 0.20)
    let cream = Color(red: 0.97, green: 0.96, blue: 0.91)

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                // TITLE AND DESCRIPTION
                VStack(alignment: .leading, spacing: 8) {

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

                // SELECTION INDICATOR
                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 24))
            }
            .foregroundStyle(cream)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 155)
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
            .contentShape(
                RoundedRectangle(cornerRadius: 22)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    NavigationStack {
        SignUpView(store: SignupStore())
    }
}
