//
//  NavigationRouter.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
import SwiftUI
import SwiftUI

struct NavigationRouter: View {
    let destination: AppDestination
    
    var body: some View {
        switch destination {
        case .main(let mainDestination):
            switch mainDestination {
            case .firstTime:
                FirstTimeView()
            case .home:
                FirstTimeView()
            }
            
        case .profile(let profileDestination):
            switch profileDestination {
            case .setup:
                ProfileSetupView()
            case .edit:
                ProfileSetupView()
            }
            
        case .recipe(let recipeDestination):
            switch recipeDestination {
            case .list:
                RecipeInputView()
            case .create:
                RecipeInputView()
            case .recipeList(let recipes):
                RecipeListView(recipes: recipes)
            case .detail(let recipe):
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
