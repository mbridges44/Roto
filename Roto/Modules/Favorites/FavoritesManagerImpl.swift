import Foundation
import SwiftData

@Observable
class FavoritesManagerImpl {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        let recipeName = recipe.name
        let descriptor = FetchDescriptor<FavoriteRecipe>(
            predicate: #Predicate<FavoriteRecipe> { favorite in
                favorite.id == recipeName
            }
        )
        
        do {
            let existingFavorites = try context.fetch(descriptor)
            if let existing = existingFavorites.first {
                // Remove from favorites
                context.delete(existing)
            } else {
                // Add to favorites
                let favoriteRecipe = FavoriteRecipe(from: recipe)
                context.insert(favoriteRecipe)
                print("Inserted favorite: " + favoriteRecipe.name)
            }
            try context.save()
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        let recipeName = recipe.name
        let descriptor = FetchDescriptor<FavoriteRecipe>(
            predicate: #Predicate<FavoriteRecipe> { favorite in
                favorite.id == recipeName
            }
        )
        
        do {
            let existingFavorites = try context.fetch(descriptor)
            return !existingFavorites.isEmpty
        } catch {
            print("Error checking favorite status: \(error)")
            return false
        }
    }
    
    func getAllFavorites() -> [Recipe] {
        let descriptor = FetchDescriptor<FavoriteRecipe>()
        do {
            let favoriteRecipes = try context.fetch(descriptor)
            return favoriteRecipes.map { $0.toRecipe() }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
}
