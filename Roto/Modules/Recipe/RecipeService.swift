//
//  RecipeService.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//
// Updated Recipe Service
final class RecipeService: RecipeServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func generateRecipes(ingredients: [String], dislikes: [String]) async throws -> [Recipe] {
        let payload = GenerateRecipePayload(ingredients: ingredients, dislikes: dislikes)
        let response: RecipeResponse = try await apiClient.postData(endpoint: "/generate", body: payload)
        
        // Convert DTOs to SwiftData models
        return response.recipe.map { $0.toModel() }
    }
}


