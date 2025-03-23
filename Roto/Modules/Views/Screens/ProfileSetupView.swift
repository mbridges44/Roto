// Fix for ProfileSetupView.swift

import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStyle) private var style
    @Environment(ProfileStateManager.self) private var profileState
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    @State private var baseIngredients: [String] = []
    @State private var dislikes: [String] = []
    @State private var newBaseIngredient: String = ""
    @State private var newDislike: String = ""
    @State private var selectedDietCategories: Set<DietCategoriesEnum> = []
    @State private var showingSaveSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.sectionSpacing) {
                // Base Pantry Ingredients Section
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Base Pantry Ingredients")
                    
                    AppStyledTextField(
                        placeholder: "Add Base Ingredient",
                        text: $newBaseIngredient,
                        onSubmit: addBaseIngredient
                    )
                    
                    if !baseIngredients.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(baseIngredients, id: \.self) { ingredient in
                                ListItemView(
                                    text: ingredient,
                                    onDelete: { deleteIngredient(ingredient) }
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                
                // Foods to Avoid Section
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Foods to Avoid")
                    
                    AppStyledTextField(
                        placeholder: "Add Food To Avoid",
                        text: $newDislike,
                        onSubmit: addDislike
                    )
                    
                    if !dislikes.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(dislikes, id: \.self) { dislike in
                                ListItemView(
                                    text: dislike,
                                    onDelete: { deleteDislike(dislike) }
                                )
                            }
                        }
                    }
                }
                
                // Dietary Restrictions Section
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Dietary Restrictions")
                    
                    ForEach(DietCategoriesEnum.allCases) { category in
                        Toggle(isOn: Binding(
                            get: { selectedDietCategories.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDietCategories.insert(category)
                                } else {
                                    selectedDietCategories.remove(category)
                                }
                            }
                        )) {
                            Text(category.rawValue)
                                .foregroundColor(style.primaryColor)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer(minLength: 32)
                
                // Save Button
                AppStyledButton(title: "Save Profile", action: saveProfileAndNavigate)
            }
            .padding(24)
        }
        .background(style.backgroundColor)
        .navigationTitle("Your Profile")
        .onAppear {
            // Load existing profile data when view appears
            loadExistingProfile()
        }
        
        // Success Overlay
        if showingSaveSuccess {
            SuccessOverlay(message: "Profile Saved!") {
                withAnimation {
                    showingSaveSuccess = false
                    isFirstLaunch = false
                    navigationVM.navigateToRecipeCreate()
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadExistingProfile() {
        // First try to get from profile state manager
        if !profileState.baseIngredients.isEmpty || !profileState.dislikes.isEmpty || !profileState.dietCategories.isEmpty {
            baseIngredients = profileState.baseIngredients
            dislikes = profileState.dislikes
            selectedDietCategories = Set(profileState.dietCategories)
            return
        }
        
        // Otherwise try to load from database
        let manager = ProfileDataManager(context: modelContext)
        if let profile = manager.loadProfile() {
            baseIngredients = profile.baseIngredients.filter { !$0.isEmpty }
            dislikes = profile.dislikes.filter { !$0.isEmpty }
            selectedDietCategories = Set(profile.dietCategories)
        }
    }
    
    private func addBaseIngredient() {
        guard !newBaseIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        baseIngredients.append(newBaseIngredient.trimmingCharacters(in: .whitespacesAndNewlines))
        newBaseIngredient = ""
    }
    
    private func deleteIngredient(_ ingredient: String) {
        baseIngredients.removeAll { $0 == ingredient }
    }
    
    private func addDislike() {
        guard !newDislike.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        dislikes.append(newDislike.trimmingCharacters(in: .whitespacesAndNewlines))
        newDislike = ""
    }
    
    private func deleteDislike(_ dislike: String) {
        dislikes.removeAll { $0 == dislike }
    }
    
    private func saveProfileAndNavigate() {
        // Clear any existing profile first
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: nil)
        if let existingProfiles = try? modelContext.fetch(fetchDescriptor) {
            for profile in existingProfiles {
                modelContext.delete(profile)
            }
        }
        
        // Create and save new profile
        let profile = UserProfile(
            baseIngredients: baseIngredients.filter { !$0.isEmpty },
            dislikes: dislikes.filter { !$0.isEmpty },
            dietCategories: Array(selectedDietCategories)
        )
        
        modelContext.insert(profile)
        try? modelContext.save()
        
        // Update the shared profile state
        profileState.baseIngredients = baseIngredients.filter { !$0.isEmpty }
        profileState.dislikes = dislikes.filter { !$0.isEmpty }
        profileState.dietCategories = Array(selectedDietCategories)
        
        withAnimation {
            showingSaveSuccess = true
        }
        
        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSaveSuccess = false
                isFirstLaunch = false
                navigationVM.navigateToRecipeCreate()
            }
        }
    }
}
