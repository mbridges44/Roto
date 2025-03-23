import SwiftUI
import SwiftData

@MainActor
class RecipeInputViewModel: ObservableObject {
    private let recipeService: RecipeServiceProtocol
    @Published var isLoading = false
    @Published var error: String?
    
    init(recipeService: RecipeServiceProtocol = RecipeService()) {
        self.recipeService = recipeService
    }
    
    func generateRecipes(ingredients: [String], dislikes: [String]) async -> [Recipe]? {
        isLoading = true
        error = nil
        
        do {
            let recipes = try await recipeService.generateRecipes(
                ingredients: ingredients,
                dislikes: dislikes
            )
            isLoading = false
            return recipes
        } catch NetworkError.invalidURL {
            error = "Invalid URL configuration"
        } catch NetworkError.serverError(let code) {
            error = "Server error: \(code)"
        } catch NetworkError.decodingError {
            error = "Error processing server response"
        } catch {
            //error = "An unexpected error occurred"
        }
        
        isLoading = false
        return nil
    }
}


struct RecipeInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject private var viewModel: RecipeInputViewModel
    
    init(viewModel: RecipeInputViewModel? = nil) {
        // Use _viewModel to initialize the StateObject wrapper
        _viewModel = StateObject(wrappedValue: viewModel ?? RecipeInputViewModel())
    }

    @State private var ingredients: [String] = []
    @State private var dislikes: [String] = []
    @State private var newIngredient: String = ""
    @State private var newDislike: String = ""
    @State private var profileDietCategories: [DietCategoriesEnum] = []

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: style.sectionSpacing) {
                  
                    
                    // Base Pantry Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "Ingredients")
                        
                        AppStyledTextField(
                            placeholder: "Eggs, Ground Beef, etc.",
                            text: $newIngredient,
                            onSubmit: addIngredientToList
                        )
                        
                        if !ingredients.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(ingredients, id: \.self) { ingredient in
                                    ListItemView(
                                        text: ingredient,
                                        onDelete: { deleteIngredient(ingredient) }
                                    )
                                }
                            }
                        }
                    }

                    RequestPreviewCard(ingredientsFromProfile: [], ingredientsFromGenerator: ingredients, dislikesFromProfile: [], dislikesFromGenerator: dislikes)
                    
                }
                .padding(24)
            }
            
            // Fixed Button Section at Bottom
            VStack {
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Divider()
                Button(action: submitData) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Generate Recipe")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "wand.and.stars")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isLoading ? style.primaryColor.opacity(0.7) : style.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(style.backgroundColor)
        }
        .background(style.backgroundColor)
        .navigationTitle("Recipe Generator")
        .onAppear {loadProfilePreferences()}
    }
        
    
    // MARK: - List Management
    
    
    private func loadProfilePreferences() {
        let profileManager = ProfileDataManager(context: modelContext)
        if let profile = profileManager.loadProfile() {
            ingredients = profile.baseIngredients
            dislikes = profile.dislikes
            profileDietCategories = profile.dietCategories
        }
    }
    
    private func addIngredientToList() {
        addToListAndClear(list: &ingredients, item: &newIngredient)
    }
    
    private func addDislikeToList() {
        addToListAndClear(list: &dislikes, item: &newDislike)
    }
    
    private func addToListAndClear(list: inout [String], item: inout String) {
        guard !item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        list.append(item.trimmingCharacters(in: .whitespacesAndNewlines))
        item = ""
    }
    
    private func deleteIngredient(_ ingredient: String) {
        ingredients.removeAll { $0 == ingredient }
    }
    
    private func deleteDislike(_ dislike: String) {
        dislikes.removeAll { $0 == dislike }
    }
    
    // MARK: - Submission Logic
    private func submitData() {
        guard !ingredients.isEmpty else {
            viewModel.error = "Please add at least one ingredient"
            return
        }
        
        Task {
            if let recipes = await viewModel.generateRecipes(
                ingredients: ingredients,
                dislikes: dislikes
            ) {
                navigationVM.navigateToRecipeList(recipes)
            }
        }
    }
}

//MARK: - UI Component
struct RequestPreviewCard: View {
    @Environment(\.appStyle) private var style
    
    @State private var ingredientsFromProfile: [String]
    @State private var ingredientsFromGenerator: [String]
    @State private var dislikesFromProfile: [String]
    @State private var dislikesFromGenerator: [String]

    
    init(ingredientsFromProfile: [String] = [], ingredientsFromGenerator: [String] = [],
         dislikesFromProfile: [String] = [],  dislikesFromGenerator: [String] = []) {
        self.ingredientsFromProfile = ingredientsFromProfile;
        self.ingredientsFromGenerator = ingredientsFromGenerator;
        self.dislikesFromProfile = dislikesFromProfile;
        self.dislikesFromGenerator = dislikesFromGenerator;
    }
    
    
    private var allIngredients: [String] {
           Array(Set(ingredientsFromProfile + ingredientsFromGenerator))
       }
       
       private var allDislikes: [String] {
           Array(Set(dislikesFromProfile + dislikesFromGenerator))
       }
       
       var body: some View {
           VStack(alignment: .leading, spacing: 12) {
               // Title
               Text("Ingredients Preview")
                   .font(.headline)
                   .foregroundColor(style.primaryColor)
               
               // Ingredients Section
               if !allIngredients.isEmpty {
                   VStack(alignment: .leading, spacing: 8) {
                       Text("INGREDIENTS")
                           .font(.caption)
                           .foregroundColor(style.primaryColor.opacity(0.7))
                       
                       FlowLayout(items: allIngredients) { ingredient in
                           Text(ingredient)
                               .font(.caption)
                               .padding(.horizontal, 8)
                               .padding(.vertical, 4)
                               .background(style.primaryColor.opacity(0.1))
                               .foregroundColor(style.primaryColor)
                               .cornerRadius(12)
                       }
                   }
               }
               
               // Divider for separation
               if !allIngredients.isEmpty && !allDislikes.isEmpty {
                   Divider()
                       .padding(.vertical, 4)
               }
               
               // Dislikes Section
               if !allDislikes.isEmpty {
                   VStack(alignment: .leading, spacing: 8) {
                       Text("DISLIKES")
                           .font(.caption)
                           .foregroundColor(style.primaryColor.opacity(0.7))
                       
                       FlowLayout(items: allDislikes) { dislike in
                           Text(dislike)
                               .font(.caption)
                               .padding(.horizontal, 8)
                               .padding(.vertical, 4)
                               .background(style.accentColor.opacity(0.1))
                               .foregroundColor(style.accentColor)
                               .cornerRadius(12)
                       }
                   }
               }
               
               // Empty state message
               if allIngredients.isEmpty && allDislikes.isEmpty {
                   HStack {
                       Spacer()
                       Text("Add ingredients to get started")
                           .font(.subheadline)
                           .foregroundColor(style.primaryColor.opacity(0.5))
                           .padding(.vertical, 12)
                       Spacer()
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

   
   // Preview provider
   struct RequestPreviewCard_Previews: PreviewProvider {
       static var previews: some View {
           VStack {
               // Empty state
               RequestPreviewCard()
                   .padding()
               
               // With data
               RequestPreviewCard(
                   ingredientsFromProfile: ["Eggs", "Milk", "Flour"],
                   ingredientsFromGenerator: ["Chicken", "Onions", "Garlic"],
                   dislikesFromProfile: ["Nuts", "Shellfish"],
                   dislikesFromGenerator: ["Olives"]
               )
               .padding()
           }
           .background(Color("BrandBackground"))
       }
   }


// MARK: - Preview

// MARK: - Mock Recipe Service
class MockRecipeService: RecipeServiceProtocol {
    var shouldSimulateError = false
    var delayInSeconds: Double = 1.0
    
    func generateRecipes(ingredients: [String], dislikes: [String]) async throws -> [Recipe] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        
        if shouldSimulateError {
            throw NetworkError.serverError(500)
        }
        
        return Recipe.mockRecipes
    }
}

// MARK: - Preview Helper
extension RecipeInputView {
    static func preview(shouldSimulateError: Bool = false, delay: Double = 1.0) -> some View {
        let mockService = MockRecipeService()
        mockService.shouldSimulateError = shouldSimulateError
        mockService.delayInSeconds = delay
        
        let viewModel = RecipeInputViewModel(recipeService: mockService)
        
        return NavigationStack {
            GlobalStyledView {
                RecipeInputView()
                    .environmentObject(NavigationViewModel())
                    .modelContainer(for: Item.self, inMemory: true)
            }
        }
    }
}

// MARK: - Preview Examples
#Preview("Normal State") {
    RecipeInputView.preview()
}

#Preview("Error State") {
    RecipeInputView.preview(shouldSimulateError: true)
}

#Preview("Quick Response") {
    RecipeInputView.preview(delay: 0.1)
}
