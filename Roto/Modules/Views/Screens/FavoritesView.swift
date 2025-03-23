//
//  FavoritesView.swift
//  Roto
//
//  Created by Michael Bridges on 2/20/25.
//
import SwiftUI

struct FavoritesView: View {
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    
    // This would eventually come from your data store
    @State private var favoriteRecipes: [Recipe] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if favoriteRecipes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48))
                            .foregroundColor(style.primaryColor.opacity(0.3))
                        
                        Text("No Favorite Recipes Yet")
                            .font(.headline)
                            .foregroundColor(style.primaryColor)
                        
                        Text("Your favorite recipes will appear here")
                            .font(.subheadline)
                            .foregroundColor(style.primaryColor.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    ForEach(favoriteRecipes, id: \.name) { recipe in
                        RecipeCard(recipe: recipe)
                            .onTapGesture {
                                navigationVM.navigateToRecipeDetail(recipe)
                            }
                    }
                }
            }
            .padding(24)
        }
        .background(style.backgroundColor)
        .navigationTitle("Favorites")
    }
}

#Preview {
    NavigationStack {
        GlobalStyledView {
            FavoritesView()
        }
    }
    .environmentObject(NavigationViewModel())
}
