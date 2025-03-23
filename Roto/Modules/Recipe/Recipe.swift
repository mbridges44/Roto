import Foundation
import SwiftData

@Model
final class Recipe {
    var name: String
    var recipeDescription: String?
    var timeEstimate: String?
    @Relationship(deleteRule: .cascade) var instructions: [Instruction]
    @Relationship(deleteRule: .cascade) var ingredients: [RecipeIngredient]
    
    init(name: String,
         description: String? = nil,
         timeEstimate: String? = nil,
         instructions: [Instruction] = [],
         ingredients: [RecipeIngredient] = []) {
        self.name = name
        self.recipeDescription = description
        self.timeEstimate = timeEstimate
        self.instructions = instructions
        self.ingredients = ingredients
    }
}

// Supporting Models
@Model
final class Instruction {
    var step: String
    var order: Int
    
    init(step: String, order: Int) {
        self.step = step
        self.order = order
    }
}

@Model
final class RecipeIngredient {
    var name: String
    var quantity: String
    
    init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
    }
}

// Extension for JSON Coding
extension Recipe {
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        let timeEstimate = try container.decodeIfPresent(String.self, forKey: .timeEstimate)
        
        // Decode instructions
        let instructionsContainer = try container.decode(Instructions.self, forKey: .instructions)
        let instructions = instructionsContainer.step.enumerated().map {
            Instruction(step: $1, order: $0)
        }
        
        // Decode ingredients
        let ingredientsContainer = try container.decode(ListOfIngredients.self, forKey: .listOfIngredients)
        let ingredients = ingredientsContainer.ingredient.map {
            RecipeIngredient(name: $0.ingredientName, quantity: $0.ingredientQuantity)
        }
        
        self.init(name: name,
                 description: description,
                 timeEstimate: timeEstimate,
                 instructions: instructions,
                 ingredients: ingredients)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(recipeDescription, forKey: .description)
        try container.encodeIfPresent(timeEstimate, forKey: .timeEstimate)
        
        // Encode instructions
        let instructionsData = Instructions(step: instructions.sorted { $0.order < $1.order }.map { $0.step })
        try container.encode(instructionsData, forKey: .instructions)
        
        // Encode ingredients
        let ingredientsData = ListOfIngredients(ingredient: ingredients.map {
            Ingredient(ingredientName: $0.name, ingredientQuantity: $0.quantity)
        })
        try container.encode(ingredientsData, forKey: .listOfIngredients)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case timeEstimate = "TimeEstimate"
        case instructions = "Instructions"
        case listOfIngredients = "ListOfIngredients"
    }
}

// Supporting Codable structures (unchanged)
struct Instructions: Codable {
    let step: [String]
    
    enum CodingKeys: String, CodingKey {
        case step = "Step"
    }
}

struct ListOfIngredients: Codable {
    let ingredient: [Ingredient]
    
    enum CodingKeys: String, CodingKey {
        case ingredient = "Ingredient"
    }
}

struct Ingredient: Codable {
    let ingredientName: String
    let ingredientQuantity: String
    
    enum CodingKeys: String, CodingKey {
        case ingredientName = "IngredientName"
        case ingredientQuantity = "IngredientQuantity"
    }
}

// Mock data extension
extension Recipe {
    static var mockRecipes: [Recipe] {
        [
            Recipe(
                name: "Homemade Pizza",
                description: "Classic homemade pizza with a crispy crust and your favorite toppings.",
                timeEstimate: "45 min",
                instructions: [
                    Instruction(step: "Make the pizza dough", order: 0),
                    Instruction(step: "Prepare toppings", order: 1),
                    Instruction(step: "Spread sauce and add toppings", order: 2),
                    Instruction(step: "Bake at 450°F for 15 minutes", order: 3)
                ],
                ingredients: [
                    RecipeIngredient(name: "Flour", quantity: "2 cups"),
                    RecipeIngredient(name: "Yeast", quantity: "1 packet"),
                    RecipeIngredient(name: "Tomato Sauce", quantity: "1 cup"),
                    RecipeIngredient(name: "Mozzarella", quantity: "2 cups")
                ]
            )
        ]
    }
}
