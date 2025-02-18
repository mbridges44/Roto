import Foundation

struct Recipe: Codable, Hashable {
    let name: String
    let description: String?
    let timeEstimate: String?
    let instructions: Instructions
    let listOfIngredients: ListOfIngredients

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case timeEstimate = "TimeEstimate"
        case instructions = "Instructions"
        case listOfIngredients = "ListOfIngredients"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(timeEstimate)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.timeEstimate == rhs.timeEstimate
    }
    
   
}

struct Instructions: Codable, Hashable {
    let step: [String]

    enum CodingKeys: String, CodingKey {
        case step = "Step"
    }
}

struct ListOfIngredients: Codable, Hashable {
    let ingredient: [Ingredient]

    enum CodingKeys: String, CodingKey {
        case ingredient = "Ingredient"
    }
}

struct Ingredient: Codable, Hashable {
    let ingredientName: String
    let ingredientQuantity: String

    enum CodingKeys: String, CodingKey {
        case ingredientName = "IngredientName"
        case ingredientQuantity = "IngredientQuantity"
    }
}
