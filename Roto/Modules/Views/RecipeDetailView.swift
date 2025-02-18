import SwiftUI

struct RecipeDetailView: View {
    // Access the dismiss action from the environment.
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe Name
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 4)
                
                // Time Estimate
                Text("Time Estimate: \(recipe.timeEstimate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Ingredients Section
                Text("Ingredients")
                    .font(.headline)
                ForEach(recipe.listOfIngredients.ingredient, id: \.ingredientName) { ingredient in
                    HStack {
                        Text(ingredient.ingredientName)
                        Spacer()
                        Text(ingredient.ingredientQuantity)
                    }
                    .padding(.vertical, 2)
                }
                
                Divider()
                
                // Instructions Section
                Text("Instructions")
                    .font(.headline)
                ForEach(recipe.instructions.step, id: \.self) { step in
                    Text("• \(step)")
                        .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample Recipe for Preview purposes.
        let sampleRecipe = Recipe(
            name: "Caramelized Onions",
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
        
        NavigationView {
            RecipeDetailView(recipe: sampleRecipe)
        }
    }
}
