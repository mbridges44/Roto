// Fix for ProfileStateManager.swift

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
            self.baseIngredients = profile.baseIngredients.filter { !$0.isEmpty }
            self.dislikes = profile.dislikes.filter { !$0.isEmpty }
            self.dietCategories = profile.dietCategories
            
            print("ProfileStateManager - Loaded profile with \(self.baseIngredients.count) ingredients and \(self.dislikes.count) dislikes")
        } else {
            print("ProfileStateManager - No profile found")
            // Clear existing values if no profile exists
            self.baseIngredients = []
            self.dislikes = []
            self.dietCategories = []
        }
    }
    
    func saveProfile(baseIngredients: [String], dislikes: [String], dietCategories: [DietCategoriesEnum]) {
        // First update our local state
        self.baseIngredients = baseIngredients.filter { !$0.isEmpty }
        self.dislikes = dislikes.filter { !$0.isEmpty }
        self.dietCategories = dietCategories
        
        // Then save to persistent storage
        let profile = UserProfile(
            baseIngredients: baseIngredients.filter { !$0.isEmpty },
            dislikes: dislikes.filter { !$0.isEmpty },
            dietCategories: dietCategories
        )
        let manager = ProfileDataManager(context: modelContext)
        manager.saveProfile(profile)
        
        print("ProfileStateManager - Saved profile with \(self.baseIngredients.count) ingredients and \(self.dislikes.count) dislikes")
    }
}
