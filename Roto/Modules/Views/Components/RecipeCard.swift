//
//  RecipeCard.swift
//  Roto
//
//  Created by Michael Bridges on 2/20/25.
//
import SwiftUI

enum RecipeSource {
    case standard(Recipe)
    case favorite(FavoriteRecipe)
    
    var name: String {
        switch self {
        case .standard(let recipe): return recipe.name
        case .favorite(let favorite): return favorite.name
        }
    }
    
    var timeEstimate: String? {
        switch self {
        case .standard(let recipe): return recipe.timeEstimate
        case .favorite(let favorite): return favorite.timeEstimate
        }
    }
    
    var description: String? {
        switch self {
        case .standard(let recipe): return recipe.recipeDescription
        case .favorite(let favorite): return favorite.recipeDescription
        }
    }
    
    var ingredients: [RecipeIngredient] {
        switch self {
        case .standard(let recipe): return recipe.ingredients
        case .favorite(let favorite): return favorite.ingredients.map {
            RecipeIngredient(name: $0.name, quantity: $0.quantity)
        }
    }
    }
    
    var favoritedDate: Date? {
        switch self {
        case .standard: return nil
        case .favorite(let favorite): return favorite.favoritedDate
        }
    }
}

struct RecipeCard: View {
    @Environment(\.appStyle) private var style
    
    private let recipeSource: RecipeSource
    
    init(recipe: Recipe) {
        self.recipeSource = .standard(recipe)
    }
    
    init(favoriteRecipe: FavoriteRecipe) {
        self.recipeSource = .favorite(favoriteRecipe)
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Time
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipeSource.name)
                        .font(.headline)
                        .foregroundColor(style.primaryColor)
                    
                    Spacer()
                    
                    if let timeEst = recipeSource.timeEstimate {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundColor(style.accentColor)
                            Text(timeEst)
                                .font(.subheadline)
                                .foregroundColor(style.primaryColor)
                        }
                    }
                }
                
                if let favoriteDate = recipeSource.favoritedDate {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(style.accentColor)
                            .imageScale(.small)
                        Text("Saved \(dateFormatter.string(from: favoriteDate))")
                            .font(.caption)
                            .foregroundColor(style.primaryColor.opacity(0.7))
                    }
                }
            }
            
            // Description
            if let description = recipeSource.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(style.primaryColor.opacity(0.8))
                    .lineLimit(2)
            }
            
            // Ingredients preview
            HStack(spacing: 8) {
                ForEach(recipeSource.ingredients.prefix(3), id: \.name) { ingredient in
                    Text(ingredient.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(style.accentColor.opacity(0.1))
                        .foregroundColor(style.accentColor)
                        .cornerRadius(12)
                }
                
                if recipeSource.ingredients.count > 3 {
                    Text("+\(recipeSource.ingredients.count - 3) more")
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
    VStack(spacing: 20) {
        // Standard recipe card
        RecipeCard(recipe: Recipe.mockRecipes[0])
        
        // Favorite recipe card
        RecipeCard(favoriteRecipe: FavoriteRecipe(
            from: Recipe.mockRecipes[1]
        ))
    }
    .padding()
    .background(Color("BrandBackground"))
}
