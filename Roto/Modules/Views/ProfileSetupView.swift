import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStyle) private var style

    @State private var baseIngredients: [String] = []
    @State private var dislikes: [String] = []
    @State private var newBaseIngredient: String = ""
    @State private var newDislike: String = ""
    @State private var selectedDietCategories: Set<DietCategoriesEnum> = []
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: style.sectionSpacing) {
                VStack(alignment: .leading, spacing: 8) {
                    AppSectionHeader(title: "Base Pantry Ingredients")
                    
                    AppStyledTextField(
                        placeholder: "Add Base Ingredient",
                        text: $newBaseIngredient,
                        onSubmit: addBaseIngredient
                    )
                
                }
                VStack(alignment: .leading, spacing: 8) {
                    AppSectionHeader(title: "Foods to Avoid")
                    // Section for Dislikes.
                    AppStyledTextField(
                        placeholder: "Add Food To Avoid",
                        text: $newDislike,
                        onSubmit: addDislike
                    )
                }
                VStack(alignment: .leading, spacing: 8) {
                    // Section for Diet
                    Section(header: AppSectionHeader(title: "Dietary Restrictions")) {
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
                            }
                        }
                    }
                    Spacer()
                    // Save Button Section.
                    Section {
                        AppStyledButton(title: "Save", action: saveProfile)
                            .padding(.top, 16)
                    }

                }
            }
            .navigationTitle("Your Profile")
            .padding(style.defaultPadding)
            .background(style.backgroundColor)
        }
    }
    
    // MARK: - Helper Functions
    
    private func addBaseIngredient() {
        guard !newBaseIngredient.isEmpty else { return }
        baseIngredients.append(newBaseIngredient)
        newBaseIngredient = ""
    }
    
    private func deleteBaseIngredient(at offsets: IndexSet) {
        baseIngredients.remove(atOffsets: offsets)
    }
    
    private func addDislike() {
        guard !newDislike.isEmpty else { return }
        dislikes.append(newDislike)
        newDislike = ""
    }
    
    private func deleteDislike(at offsets: IndexSet) {
        dislikes.remove(atOffsets: offsets)
    }
    
    private func saveProfile() {
        let profile = UserProfile(
            baseIngredients: baseIngredients,
            dislikes: dislikes,
            dietCategories: Array(selectedDietCategories)
        )
        let manager = ProfileDataManager(context: modelContext)
        manager.saveProfile(profile)
    }
}

#Preview {
    GlobalStyledView {
        ProfileSetupView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
