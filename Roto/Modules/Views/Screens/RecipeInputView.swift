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
    @Environment(ProfileStateManager.self) private var profileState
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject private var viewModel: RecipeInputViewModel
    
    init(viewModel: RecipeInputViewModel? = nil) {
        // Use _viewModel to initialize the StateObject wrapper
        _viewModel = StateObject(wrappedValue: viewModel ?? RecipeInputViewModel())
    }

    @State private var ingredients: [String] = []
    @State private var newIngredient: String = ""

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
                }
                .padding(24)
            }
            
            // Fixed Section at Bottom
            VStack(spacing: 16) {
                // Request Summary Card
                RequestPreviewCard(
                    ingredientsFromProfile: profileState.baseIngredients,
                    ingredientsFromGenerator: ingredients,
                    dislikesFromProfile: profileState.dislikes
                )
                .padding(.horizontal, 24)
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Divider()
                
                // Generate Button
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
                .padding(.bottom, 16)
            }
            .background(style.backgroundColor)
        }
        .background(style.backgroundColor)
        .navigationTitle("Recipe Generator")
    }
        
    // MARK: - List Management
    
    private func addIngredientToList() {
        addToListAndClear(list: &ingredients, item: &newIngredient)
    }
    
    private func addToListAndClear(list: inout [String], item: inout String) {
        guard !item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        list.append(item.trimmingCharacters(in: .whitespacesAndNewlines))
        item = ""
    }
    
    private func deleteIngredient(_ ingredient: String) {
        ingredients.removeAll { $0 == ingredient }
    }
    
    // MARK: - Submission Logic
    private func submitData() {
        guard !ingredients.isEmpty || !profileState.baseIngredients.isEmpty else {
            viewModel.error = "Please add at least one ingredient"
            return
        }
        
        // Combine current ingredients with profile ingredients
        let allIngredients = ingredients + profileState.baseIngredients
        
        Task {
            if let recipes = await viewModel.generateRecipes(
                ingredients: allIngredients,
                dislikes: profileState.dislikes
            ) {
                navigationVM.navigateToRecipeList(recipes)
            }
        }
    }
}
