//
//  MockFavoritesManager.swift
//  Roto
//
//  Created by Michael Bridges on 2/23/25.
//
import Foundation
import SwiftData
import Foundation
import SwiftData

class MockFavoritesManager: FavoritesManager {
    private var mockFavorites: [FavoriteRecipe]
    private var favoriteStates: [String: Bool] = [:]
    
    init(mockRecipes: [FavoriteRecipe] = FavoriteRecipe.mockFavorites)  {
        self.mockFavorites = mockRecipes
    }
    
    func getAllFavorites() -> [FavoriteRecipe] {
        return mockFavorites
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        return favoriteStates[recipe.name] ?? false
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        if let index = mockFavorites.firstIndex(where: { $0.name == recipe.name }) {
            mockFavorites.remove(at: index)
            favoriteStates[recipe.name] = false
        } else {
            mockFavorites.append(FavoriteRecipe.init(from: recipe))
            favoriteStates[recipe.name] = true
        }
    }
}

// Usage in previews:
extension FavoritesManagerImpl {
    static var preview: FavoritesManager {
        MockFavoritesManager()
    }
}
