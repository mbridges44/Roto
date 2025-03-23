//
//  RecipeListView.swift
//  Roto
//
//  Created by Michael Bridges on 2/18/25.
//
import SwiftUI

struct RecipeListView: View {
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    
    let recipes: [Recipe]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(recipes, id: \.name) { recipe in
                    RecipeCard(recipe: recipe)
                        .onTapGesture {
                            navigationVM.navigateToRecipeDetail(recipe)
                        }
                }
            }
            .padding(24)
        }
        .background(style.backgroundColor)
        .navigationTitle("Choose a Recipe")
    }
}

// Helper view for individual recipe cards
private struct RecipeCard: View {
    @Environment(\.appStyle) private var style
    
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Time
            HStack {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(style.primaryColor)
                
                Spacer()
                
                if let timeEst = recipe.timeEstimate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(style.accentColor)
                        Text(timeEst)
                            .font(.subheadline)
                            .foregroundColor(style.primaryColor)
                    }
                }
            }
            
            // Description
            if let description = recipe.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(style.primaryColor.opacity(0.8))
                    .lineLimit(2)
            }
            
            // Ingredients preview
            HStack(spacing: 8) {
                ForEach(recipe.listOfIngredients.ingredient.prefix(3), id: \.ingredientName) { ingredient in
                    Text(ingredient.ingredientName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(style.accentColor.opacity(0.1))
                        .foregroundColor(style.accentColor)
                        .cornerRadius(12)
                }
                
                if recipe.listOfIngredients.ingredient.count > 3 {
                    Text("+\(recipe.listOfIngredients.ingredient.count - 3) more")
                        .font(.caption)
                        .foregroundColor(style.primaryColor.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    NavigationStack {
        GlobalStyledView {
            RecipeListView(recipes: [
                Recipe(
                    name: "Caramelized Onions",
                    description: "Sweet and savory caramelized onions perfect for topping burgers or adding to soups.",
                    timeEstimate: "45 min",
                    instructions: Instructions(step: ["Step 1", "Step 2"]),
                    listOfIngredients: ListOfIngredients(ingredient: [
                        Ingredient(ingredientName: "Onions", ingredientQuantity: "2 large"),
                        Ingredient(ingredientName: "Olive Oil", ingredientQuantity: "2 tbsp"),
                        Ingredient(ingredientName: "Salt", ingredientQuantity: "1 tsp"),
                        Ingredient(ingredientName: "Sugar", ingredientQuantity: "1 tsp")
                    ])
                ),
                Recipe(
                    name: "Garlic Butter Pasta",
                    description: "Simple and delicious pasta tossed in garlic butter sauce.",
                    timeEstimate: "20 min",
                    instructions: Instructions(step: ["Step 1", "Step 2"]),
                    listOfIngredients: ListOfIngredients(ingredient: [
                        Ingredient(ingredientName: "Pasta", ingredientQuantity: "8 oz"),
                        Ingredient(ingredientName: "Butter", ingredientQuantity: "4 tbsp"),
                        Ingredient(ingredientName: "Garlic", ingredientQuantity: "4 cloves")
                    ])
                )
            ])
        }
    }
    .environmentObject(NavigationViewModel())
}
