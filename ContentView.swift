//
//  ContentView.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .padding()

                Spacer()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .tabViewStyle(.automatic)
        .overlay(
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                ExerciseLogView()
                    .tabItem {
                        Label("Workouts", systemImage: "list.bullet.rectangle")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        )
    }
}

#Preview {
    ContentView()
}
