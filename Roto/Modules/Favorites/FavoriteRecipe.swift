import SwiftData
import Foundation

@Model
final class FavoriteRecipe {
    var id: String
    var name: String
    var recipeDescription: String?
    var timeEstimate: String?
    var favoritedDate: Date
    @Relationship(deleteRule: .cascade, inverse: \SavedInstruction.recipe) var instructions: [SavedInstruction]
    @Relationship(deleteRule: .cascade, inverse: \SavedIngredient.recipe) var ingredients: [SavedIngredient]
    
    init(from recipe: Recipe, favoritedDate: Date = Date()) {
        self.id = recipe.name
        self.name = recipe.name
        self.recipeDescription = recipe.recipeDescription
        self.timeEstimate = recipe.timeEstimate
        self.favoritedDate = favoritedDate
        self.instructions = []
        self.ingredients = []
        
        // Add instructions with proper backlink
        recipe.instructions.forEach { instruction in
            let savedInstruction = SavedInstruction(
                step: instruction.step,
                order: instruction.order,
                recipe: self
            )
            self.instructions.append(savedInstruction)
        }
        
        // Add ingredients with proper backlink
        recipe.ingredients.forEach { ingredient in
            let savedIngredient = SavedIngredient(
                name: ingredient.name,
                quantity: ingredient.quantity,
                recipe: self
            )
            self.ingredients.append(savedIngredient)
        }
    }
    
    func toRecipe() -> Recipe {
        let sortedInstructions = instructions.sorted { $0.order < $1.order }
        
        // Create instructions array
        let recipeInstructions = sortedInstructions.map { savedInstruction in
            Instruction(step: savedInstruction.step, order: savedInstruction.order)
        }
        
        // Create ingredients array
        let recipeIngredients = ingredients.map { savedIngredient in
            RecipeIngredient(name: savedIngredient.name, quantity: savedIngredient.quantity)
        }
        print("Returning Recipe from fav")
        // Create and return the Recipe
        return Recipe(
            name: name,
            description: recipeDescription,
            timeEstimate: timeEstimate,
            instructions: recipeInstructions,
            ingredients: recipeIngredients
        )
    }
}

@Model
final class SavedIngredient {
    var name: String
    var quantity: String
    var recipe: FavoriteRecipe?
    
    init(name: String, quantity: String, recipe: FavoriteRecipe? = nil) {
        self.name = name
        self.quantity = quantity
        self.recipe = recipe
    }
}

@Model
final class SavedInstruction {
    var step: String
    var order: Int
    var recipe: FavoriteRecipe?
    
    init(step: String, order: Int, recipe: FavoriteRecipe? = nil) {
        self.step = step
        self.order = order
        self.recipe = recipe
    }
}

extension FavoriteRecipe {
    static var mockFavorites: [FavoriteRecipe] {
        Recipe.mockRecipes.map { FavoriteRecipe(from: $0, favoritedDate: Date()) }
    }
}
