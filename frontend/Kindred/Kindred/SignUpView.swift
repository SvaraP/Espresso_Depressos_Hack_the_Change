//
//  SignUpView.swift
//  Kindred
//
//  Created by svara on 11/7/26.
//


import SwiftUI

struct SignUpView: View {

    let forestGreen = Color(red: 0.12, green: 0.28, blue: 0.20)
    let cream = Color(red: 0.97, green: 0.96, blue: 0.91)

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

                // FULL-SCREEN FROSTED OVERLAY
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()

                // SIGN UP CONTENT
                VStack(alignment: .leading, spacing: 12) {

                    Text("Create an account")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(forestGreen)

                    Text("How would you like to contribute?")
                        .font(.system(size: 20))
                        .foregroundStyle(forestGreen)
                        .padding(.bottom, 25)

                    // ROLE SELECTION CARDS
                    VStack(spacing: 20) {

                        RoleSelectionCard(
                            title: "Senior",
                            description: "Stay active, social,\nand supported"
                        ) {
                            print("Senior selected")
                        }

                        RoleSelectionCard(
                            title: "Youth / Mentee",
                            description: "Make a difference,\nlearn, and grow"
                        ) {
                            print("Youth selected")
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 85)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .topLeading
                )
            }
        }
    }
}


// REUSABLE ROLE SELECTION CARD
struct RoleSelectionCard: View {

    let title: String
    let description: String
    let action: () -> Void

    let forestGreen = Color(red: 0.12, green: 0.28, blue: 0.20)
    let cream = Color(red: 0.97, green: 0.96, blue: 0.91)

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                // TITLE AND DESCRIPTION
                VStack(alignment: .leading, spacing: 8) {

                    Text(title)
                        .font(.system(size: 30, weight: .semibold))

                    Text(description)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                // RIGHT ARROW
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
            }
            .foregroundStyle(forestGreen)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 155)
            .background {

                // IMAGE INSIDE THE CARD
                GeometryReader { cardGeometry in
                    ZStack {

                        // Base color
                        Color.green.opacity(0.05)

                        // Faded background image
                        Image("WelcomeBackground")
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: cardGeometry.size.width,
                                height: cardGeometry.size.height
                            )
                            .clipped()
                            .opacity(0.2)

                        // Frosted overlay
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
                    }
                    .frame(
                        width: cardGeometry.size.width,
                        height: cardGeometry.size.height
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        Color.white.opacity(0.45),
                        lineWidth: 1
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
        SignUpView()
    }
}
