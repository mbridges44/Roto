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

struct RecipeInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStyle) private var style
    @Environment(ProfileStateManager.self) private var profileState
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @StateObject private var viewModel: RecipeInputViewModel
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    // Focus state management
    enum Field: Hashable {
        case ingredient, notes
    }
    @FocusState private var focusedField: Field?
    
    init(viewModel: RecipeInputViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? RecipeInputViewModel())
    }

    @State private var ingredients: [String] = []
    @State private var newIngredient: String = ""
    @State private var notes: String = ""
    private let maxNotesLength = 300

    var body: some View {
        // Main content area with scrollable content
        VStack(spacing: 0) {
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: style.sectionSpacing) {
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "Ingredients")
                        
                        HStack(spacing: 8) {
                            TextField("Eggs, Ground Beef, etc.", text: $newIngredient)
                                .focused($focusedField, equals: .ingredient)
                                .submitLabel(.done)
                                .onSubmit {
                                    addIngredientToList()
                                }
                                .appInputField(style)
                            
                            Button(action: addIngredientToList) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(style.accentColor)
                                    .imageScale(.large)
                            }
                            .padding(.trailing, 4)
                        }
                        
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
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "Special Requests")
                        
                        TextField("\"Only slow cooker recipes\" or \"Light meals perfect for spring\"", text: $notes, axis: .vertical)
                            .focused($focusedField, equals: .notes)
                            .submitLabel(.done)
                            .lineLimit(3)
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
                    
                    // Request Summary Card
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
                    
                    // Add extra space at the bottom to ensure all content is visible
                    // when the generate button shows above the keyboard
                    Spacer()
                        .frame(height: keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight + 16 : 16)
                    
                    
                    // Bottom button container that stays at the bottom
                    VStack(spacing: 0) {
                        Divider()
                        
                        // Generate Button - fixed at the bottom
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
                    // Use padding based on keyboard presence
                    .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight - 16 : 0)
                }
                .padding(24)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        focusedField = nil
                    }
            )
            
            Spacer(minLength: 0)
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil // This dismisses the keyboard
                }
            }
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
        // Dismiss keyboard when submitting
        focusedField = nil
        
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
