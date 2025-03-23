//
//  RecipeDestinations.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
// Recipe feature navigation
enum RecipeDestination: Hashable {
    case list
    case create
    case recipeList([Recipe])
    case detail(Recipe)
    
    
    static func == (lhs: RecipeDestination, rhs: RecipeDestination) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list):
            return true
        case (.create, .create):
            return true
        case (.recipeList(let recipes1), .recipeList(let recipes2)):
            return recipes1.map { $0.name } == recipes2.map { $0.name }
        case (.detail(let recipe1), .detail(let recipe2)):
            return recipe1.name == recipe2.name
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .list:
            hasher.combine(0)
        case .create:
            hasher.combine(1)
        case .recipeList(let recipes):
            hasher.combine(2)
            recipes.forEach { hasher.combine($0.name) }
        case .detail(let recipe):
            hasher.combine(3)
            hasher.combine(recipe.name)
        }
    }
}
