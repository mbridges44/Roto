import Foundation
import SwiftData

// API Response Models (for JSON decoding)
struct RecipeResponse: Decodable {
    let recipe: [RecipeDTO]
}

// Data Transfer Object for JSON
struct RecipeDTO: Decodable {
    let name: String
    let description: String?
    let timeEstimate: String?
    let instructions: InstructionsDTO
    let listOfIngredients: ListOfIngredientsDTO

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case timeEstimate = "TimeEstimate"
        case instructions = "Instructions"
        case listOfIngredients = "ListOfIngredients"
    }
    
    // Convert DTO to SwiftData model
    func toModel() -> Recipe {
        // Create instructions
        let modelInstructions = instructions.step.enumerated().map { index, step in
            Instruction(step: step, order: index)
        }
        
        // Create ingredients
        let modelIngredients = listOfIngredients.ingredient.map { ingredient in
            RecipeIngredient(
                name: ingredient.ingredientName,
                quantity: ingredient.ingredientQuantity
            )
        }
        
        // Create recipe
        return Recipe(
            name: name,
            description: description,
            timeEstimate: timeEstimate,
            instructions: modelInstructions,
            ingredients: modelIngredients
        )
    }
}

struct InstructionsDTO: Decodable {
    let step: [String]

    enum CodingKeys: String, CodingKey {
        case step = "Step"
    }
}

struct ListOfIngredientsDTO: Decodable {
    let ingredient: [IngredientDTO]

    enum CodingKeys: String, CodingKey {
        case ingredient = "Ingredient"
    }
}

struct IngredientDTO: Decodable {
    let ingredientName: String
    let ingredientQuantity: String

    enum CodingKeys: String, CodingKey {
        case ingredientName = "IngredientName"
        case ingredientQuantity = "IngredientQuantity"
    }
}


