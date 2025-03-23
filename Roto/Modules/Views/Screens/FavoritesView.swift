import SwiftUI

struct FavoritesView: View {
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @Environment(\.modelContext) private var modelContext
    
    let favoritesManager: FavoritesManager
    
    init(favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
    }
    
    var body: some View {
        NavigationStack(path: $navigationVM.path) {
            FavoritesContentView(
                favoriteRecipes: favoritesManager.getAllFavorites(),
                style: style,
                navigationVM: navigationVM
            )
            .navigationTitle("Saved Recipes")
            .navigationDestination(for: AppDestination.self) { destination in
                NavigationRouter(destination: destination)
            }
        }
    }
}

// Separate view for the content
private struct FavoritesContentView: View {
    let favoriteRecipes: [FavoriteRecipe]
    let style: AppStyleConfig
    let navigationVM: NavigationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if favoriteRecipes.isEmpty {
                    EmptyStateView(style: style)
                } else {
                    FavoriteRecipeListView(
                        recipes: favoriteRecipes,
                        style: style,
                        navigationVM: navigationVM
                    )
                }
            }
            .background(style.backgroundColor)
            .padding(24)
        }
        .background(style.backgroundColor)
    }
}

// Empty state view component
private struct EmptyStateView: View {
    let style: AppStyleConfig
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(style.primaryColor.opacity(0.3))
            
            Text("Nothing Saved Yet")
                .font(.headline)
                .foregroundColor(style.primaryColor)
            
            Text("Here you can find recipes you've saved")
                .font(.subheadline)
                .foregroundColor(style.primaryColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// Recipe list component
private struct FavoriteRecipeListView: View {
    let recipes: [FavoriteRecipe]
    let style: AppStyleConfig
    let navigationVM: NavigationViewModel
    
    var body: some View {
        ForEach(recipes, id: \.name) { recipe in
            RecipeCard(favoriteRecipe: recipe)
                .onTapGesture {
                    navigationVM.navigateToRecipeDetail(recipe.toRecipe())
                }
        }
    }
}

// Preview provider
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                GlobalStyledView {
                    FavoritesView(favoritesManager: MockFavoritesManager())
                }
            }
            .previewDisplayName("With Favorites")
            
            NavigationStack {
                GlobalStyledView {
                    FavoritesView(favoritesManager: MockFavoritesManager(mockRecipes: []))
                }
            }
            .previewDisplayName("Empty State")
        }
        .environmentObject(NavigationViewModel())
    }
}
