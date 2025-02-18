//
//  NavigationViewModel.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
import SwiftUI
class NavigationViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    // Profile Navigation
    func navigateToProfileSetup() {
        print("NavigationVM: Navigating to profile setup")
        path.append(AppDestination.profile(.setup))
    }
    
    func navigateToProfileEdit() {
        print("NavigationVM: Navigating to profile edit")
        path.append(AppDestination.profile(.edit))
    }
    
    // Recipe Navigation
    func navigateToRecipeList() {
        print("NavigationVM: Navigating to recipe list")
        path.append(AppDestination.recipe(.list))
    }
    
    func navigateToRecipeCreate() {
        print("NavigationVM: Navigating to recipe create")
        path.append(AppDestination.recipe(.create))
    }
    
    func navigateToRecipeList(_ recipes: [Recipe]) {
        print("NavigationVM: Navigating to recipe list with \(recipes.count) recipes")
        path.append(AppDestination.recipe(.recipeList(recipes)))
    }
    
    func navigateToRecipeDetail(_ recipe: Recipe) {
        print("NavigationVM: Attempting to navigate to recipe detail for: \(recipe.name)")
        path.append(AppDestination.recipe(.detail(recipe)))
    }
    
    // Common Navigation Actions
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func clearNavigation() {
        path.removeLast(path.count)
    }
}
