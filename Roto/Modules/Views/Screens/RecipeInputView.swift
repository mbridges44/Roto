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
    
    func generateRecipes(ingredients: [String], dislikes: [String], notes: String) async -> [Recipe]? {
        isLoading = true
        error = nil
        
        do {
            // Update to include notes in the recipe generation
            let recipes = try await recipeService.generateRecipes(
                ingredients: ingredients,
                dislikes: dislikes,
                notes: notes
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


// MARK: - IngredientsSection
private struct IngredientsSection: View {
    @Binding var ingredients: [String]
    @Binding var newIngredient: String
    let style: AppStyleConfig
    let onAddIngredient: () -> Void
    let onDeleteIngredient: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Ingredients")
            
            AppStyledTextField(
                placeholder: "Eggs, Chicken Breast, BBQ Sauce, etc.",
                text: $newIngredient,
                onSubmit: onAddIngredient
            )
            
            if !ingredients.isEmpty {
                VStack(spacing: 8) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        ListItemView(
                            text: ingredient,
                            onDelete: { onDeleteIngredient(ingredient) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - NotesSection
private struct NotesSection: View {
    @Binding var notes: String
    let maxNotesLength: Int
    let style: AppStyleConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Any Requests?")
            
            TextField("\"Only slow cooker recipes\" or \"Light meals perfect for spring\"", text: $notes, axis: .vertical)
                .lineLimit(1)
                .onChange(of: notes) { _, newValue in
                    if newValue.count > maxNotesLength {
                        notes = String(newValue.prefix(maxNotesLength))
                    }
                }
                .appInputField(style)
            
            HStack {
                Spacer()
                Text("\(notes.count)/\(maxNotesLength)")
                    .font(.caption)
                    .foregroundColor(
                        notes.count > Int(Double(maxNotesLength) * 0.8) ?
                            (notes.count > maxNotesLength ? .red : .orange) :
                            style.primaryColor.opacity(0.5)
                    )
            }
        }
    }
}

// MARK: - RecipeInputView
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
    @State private var notes: String = ""
    private let maxNotesLength = 300

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: style.sectionSpacing) {
                    // Ingredients Section
                    IngredientsSection(
                        ingredients: $ingredients,
                        newIngredient: $newIngredient,
                        style: style,
                        onAddIngredient: addIngredientToList,
                        onDeleteIngredient: deleteIngredient
                    )
                    
                    // Notes Section
                    NotesSection(
                        notes: $notes,
                        maxNotesLength: maxNotesLength,
                        style: style
                    )
                    
                    // Request Summary Card - moved to the scrollable area
                    RequestPreviewCard(
                        ingredientsFromProfile: profileState.baseIngredients,
                        ingredientsFromGenerator: ingredients,
                        dislikesFromProfile: profileState.dislikes,
                        notes: notes
                    )
                    .padding(.vertical, 16)
                    
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Add some space at the bottom for better scrolling experience
                    Spacer()
                        .frame(height: 16)
                }
                .padding(24)
            }
            
            Divider()
            
            // Generate Button - remains fixed at the bottom
            Button(action: submitData) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Generate Recipes")
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
        
        // Trim the notes if necessary
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNotes = trimmedNotes.count > maxNotesLength ?
                        String(trimmedNotes.prefix(maxNotesLength)) :
                        trimmedNotes
        
        Task {
            if let recipes = await viewModel.generateRecipes(
                ingredients: allIngredients,
                dislikes: profileState.dislikes,
                notes: finalNotes
            ) {
                navigationVM.navigateToRecipeList(recipes)
            }
        }
    }
}
// MARK: - Preview Provider
struct RecipeInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GlobalStyledView {
                RecipeInputView()
                    .environment(createMockProfileState())
            }
        }
        .environmentObject(NavigationViewModel())
    }
    
    // Helper function to create a mock profile state
    static func createMockProfileState() -> ProfileStateManager {
        let context = try! ModelContainer(for: UserProfile.self).mainContext
        let state = ProfileStateManager(modelContext: context)
        
        // Add some mock data for preview purposes
        state.baseIngredients = ["Flour", "Sugar", "Salt"]
        state.dislikes = ["Peanuts"]
        
        return state
    }
}
