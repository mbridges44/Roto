import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.sectionSpacing) {
                // Header Section with Description and Time
                VStack(alignment: .leading, spacing: 16) {
                    if let description = recipe.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(style.primaryColor)
                    }
                    
                    if let timeEstimate = recipe.timeEstimate {
                        // Time Estimate Card
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(style.accentColor)
                            Text(timeEstimate)
                                .font(.headline)
                                .foregroundColor(style.primaryColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                   
                }
                .padding(.bottom, 8)
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "INGREDIENTS")
                    
                    VStack(spacing: 8) {
                        ForEach(recipe.listOfIngredients.ingredient, id: \.ingredientName) { ingredient in
                            HStack {
                                Text(ingredient.ingredientName)
                                    .font(.body)
                                    .foregroundColor(style.primaryColor)
                                Spacer()
                                Text(ingredient.ingredientQuantity)
                                    .font(.body)
                                    .foregroundColor(style.primaryColor.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Instructions Section
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "INSTRUCTIONS")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(recipe.instructions.step.enumerated()), id: \.element) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Step Number Circle
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(style.accentColor)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(style.accentColor.opacity(0.1))
                                    )
                                
                                Text(step)
                                    .font(.body)
                                    .foregroundColor(style.primaryColor)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.trailing, 8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(24)
        }
        .background(style.backgroundColor)
        .navigationTitle(recipe.name)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRecipe = Recipe(
            name: "Caramelized Onions",
            description: "A delicious sweet yet savory topping for any dish.",
            timeEstimate: "45 minutes",
            instructions: Instructions(step: [
                "Chop the onions.",
                "Caramelize the onions in a pan with some olive oil over low heat, stirring occasionally, until they are golden brown and softened (about 30-40 minutes).",
                "Serve as a side dish or use as a topping for burgers, sandwiches, or soups."
            ]),
            listOfIngredients: ListOfIngredients(ingredient: [
                Ingredient(ingredientName: "Onions, Chopped", ingredientQuantity: "2 large"),
                Ingredient(ingredientName: "Olive Oil", ingredientQuantity: "2 tablespoons")
            ])
        )
        
        NavigationStack {
            GlobalStyledView {
                RecipeDetailView(recipe: sampleRecipe)
            }
        }
        .environmentObject(NavigationViewModel())
    }
}
