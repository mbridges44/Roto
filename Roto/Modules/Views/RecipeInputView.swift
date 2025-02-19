import SwiftUI
import SwiftData

struct RecipeInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStyle) private var style
    @EnvironmentObject private var navigationVM: NavigationViewModel
    
    @State private var ingredients: [String] = []
    @State private var dislikes: [String] = []
    @State private var newIngredient: String = ""
    @State private var newDislike: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: style.sectionSpacing) {
                    // Base Pantry Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "YOUR PANTRY INGREDIENTS")
                        
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
                    
                    // Foods to Avoid Section
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "FOODS TO AVOID")
                        
                        AppStyledTextField(
                            placeholder: "Peanuts, Tomatos, Olive, etc.",
                            text: $newDislike,
                            onSubmit: addDislikeToList
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
                }
                .padding(24)
            }
            
            // Fixed Button Section at Bottom
            VStack {
                Divider()
                Button(action: submitData) {
                    HStack {
                        if isLoading {
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
                    .background(isLoading ? style.primaryColor.opacity(0.7) : style.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
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
        print("Starting recipe generation...")
        guard !ingredients.isEmpty else {
            print("No ingredients provided")
            return
        }
        
        let payload: [String: Any] = [
            "ingredients": ingredients,
            "dislikes": dislikes
        ]
        
        print("Payload:", payload)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("Error: Could not serialize data to JSON")
            return
        }
        
        isLoading = true
        let config = ApiConfig()
        let client = RestClient(apiConfig: config)
        
        client.postData(requestBody: jsonData) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let data):
                    print("Received API response data")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response string:", responseString)
                        if let recipes = RecipeResponse.decodeRecipes(from: responseString) {
                            print("Successfully decoded \(recipes.count) recipes")
                            navigationVM.navigateToRecipeList(recipes)
                        } else {
                            print("Failed to decode recipes from response string")
                        }
                    } else {
                        print("Could not convert response data to string")
                    }
                    
                case .failure(let error):
                    print("Error submitting data:", error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlobalStyledView {
            RecipeInputView()
        }
    }

    .modelContainer(for: Item.self, inMemory: true)
    .environmentObject(NavigationViewModel())
}
