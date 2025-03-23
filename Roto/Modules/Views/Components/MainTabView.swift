//
//  MainTabView.swift
//  Roto
//
//  Created by Michael Bridges on 2/20/25.
//
import SwiftUI

struct MainTabView: View {
    @Environment(\.appStyle) private var style
    @StateObject private var navigationVM = NavigationViewModel()
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @Environment(\.modelContext) private var modelContext

    
    var body: some View {
        if isFirstLaunch {
            FirstTimeView()
        } else {
            TabView {
                // Create Recipe Tab
                NavigationStack(path: $navigationVM.path) {
                    RecipeInputView()
                        .navigationDestination(for: AppDestination.self) { destination in
                            NavigationRouter(destination: destination)
                        }
                }
                .tabItem {
                    Label("Create", systemImage: "wand.and.stars")
                }

                // Favorites Tab
                NavigationStack {
                    FavoritesView(favoritesManager: FavoritesManagerImpl(context:modelContext))
                        .navigationTitle("Favorites View")
                }
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

                // Profile Tab
                NavigationStack {
                    ProfileSetupView()
                        .navigationTitle("Profile")
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            }
            .tint(style.primaryColor) // Use your app's primary color for the tab bar
            .environmentObject(navigationVM)
        }
    }
}

// Preview provider
#Preview {
    GlobalStyledView {
        MainTabView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
