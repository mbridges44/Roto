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



#Preview {
    NavigationStack {
        GlobalStyledView {
            RecipeListView(recipes: Recipe.mockRecipes)
        }
    }
    .environmentObject(NavigationViewModel())
}

