//
//  ProfileStateManager.swift
//  Roto
//
//  Created by Michael Bridges on 3/23/25.
//


import SwiftUI
import SwiftData
import Combine

@Observable
class ProfileStateManager {
    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    var baseIngredients: [String] = []
    var dislikes: [String] = []
    var dietCategories: [DietCategoriesEnum] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshProfile()
    }
    
    func refreshProfile() {
        let profileManager = ProfileDataManager(context: modelContext)
        if let profile = profileManager.loadProfile() {
            self.baseIngredients = profile.baseIngredients
            self.dislikes = profile.dislikes
            self.dietCategories = profile.dietCategories
        }
    }
}
