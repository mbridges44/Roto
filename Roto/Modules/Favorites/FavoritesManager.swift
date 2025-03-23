//
//  Untitled 2.swift
//  Roto
//
//  Created by Michael Bridges on 2/23/25.
//
protocol FavoritesManager {
    func getAllFavorites() -> [FavoriteRecipe]
    func isFavorite(_ recipe: Recipe) -> Bool
    func toggleFavorite(_ recipe: Recipe)
}

