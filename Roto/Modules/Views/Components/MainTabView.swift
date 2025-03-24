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
                        .navigationTitle("Saved Recipes")
                }
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
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
            .tint(style.primaryColor)
            .onAppear {
                // Customize tab bar background color
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor(Color("TabBackground")) // Use our custom tab bar background color
                
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            .environmentObject(navigationVM)
        }
    }
}
