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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {

                // Background image
                Image("WelcomeBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Text layered over the image
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
                        .font(.system(size: 30, weight: .regular))
                        .lineSpacing(1)
                }
                .foregroundStyle(cream)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal,28)
                .padding(.vertical, 10)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                //.padding(.horizontal, -28)
                .padding(.top, 85)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }
}

#Preview {
    ContentView()
}
