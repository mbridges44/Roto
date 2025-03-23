//
//  RecipeServiceProtocol.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//
protocol RecipeServiceProtocol {
    func generateRecipes(ingredients: [String], dislikes: [String]) async throws -> [Recipe]
}
