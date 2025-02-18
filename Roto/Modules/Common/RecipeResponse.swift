//
//  RecipeResponse.swift
//  Roto
//
//  Created by Michael Bridges on 2/18/25.
//
import Foundation

struct RecipeResponse: Decodable {
    let recipe: [Recipe]
    
    
    /// Converts a JSON string into an array of Recipe objects.
    static func decodeRecipes(from jsonString: String) -> [Recipe]? {
        guard let data = jsonString.data(using: .utf8) else {
            print("Error: Could not convert string to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            // Decode the entire JSON into RecipeResponse
            let response = try decoder.decode(RecipeResponse.self, from: data)
            return response.recipe
        } catch {
            print("Error decoding recipes: \(error)")
            return nil
        }
    }

}


