//
//  ContentView.swift
//  Kindred
//
//  Created by svara on 11/7/26.
//


import SwiftUI

struct ContentView: View {

    let forestGreen = Color(red: 0.12, green: 0.28, blue: 0.20)
    let cream = Color(red: 0.97, green: 0.96, blue: 0.91)
    @State private var signupStore = SignupStore()

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

                // MAIN CONTENT
                VStack(spacing: 0) {

                    // KINDRED TITLE SECTION
                    VStack(alignment: .leading, spacing: 2) {

                        Text("Kindred")
                            .font(
                                .system(
                                    size: 75,
                                    weight: .bold,
                                    design: .default
                                )
                            )

                        Text("Fostering Growth \nthrough connection.")
                            .font(
                                .system(
                                    size: 30,
                                    weight: .regular
                                )
                            )
                    }
                    .foregroundStyle(cream)
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
                    .padding(.top, 85)

                    Spacer()

                    // BOTTOM BUTTONS
                    VStack(spacing: 12) {

                        // SIGN UP BUTTON
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Sign Up")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(cream)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(forestGreen.opacity(0.85))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                        }

                        // LOG IN BUTTON
                        Button {
                            print("Log In tapped")
                        } label: {
                            Text("Log In")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(forestGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(cream.opacity(0.85))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                        }
                    }
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

#Preview {
    ContentView()
}
