import SwiftUI
import SwiftData

struct RecipeInputView: View {
    @Environment(\.modelContext) private var modelContext
    @State var ingredients: [String] = [] // List of ingredients
    @State var dislikes: [String] = []
    @State var newIngredient: String = "" // Temporary input for adding a new ingredient
    @State var newDislike: String = ""    // Temporary input for adding a new dislike

    // New state variables for navigation.
    @State private var recipe: Recipe?
    @State private var showRecipeDetail: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Pantry")) {
                    if !ingredients.isEmpty {
                        List {
                            ForEach(ingredients, id: \.self) { ingredient in
                                Text(ingredient)
                            }
                            .onDelete(perform: deleteIngredient)
                        }
                    }
                    TextField("Add Ingredient", text: $newIngredient)
                    Button("Add") {
                        addIngredientToList()
                    }
                }
                
                Section(header: Text("Dislikes")) {
                    if !dislikes.isEmpty {
                        List {
                            ForEach(dislikes, id: \.self) { dislike in
                                Text(dislike)
                            }
                            .onDelete(perform: deleteDislike)
                        }
                    }
                    TextField("Add Dislike", text: $newDislike)
                    Button("Add") {
                        addDislikeToList()
                    }
                }
                
                Section {
                    Button("Submit") {
                        submitData()
                    }
                }
            }
            .navigationTitle("Recipe Generator")
            // Hidden NavigationLink to trigger navigation once recipe is available.
            .background(
                NavigationLink(
                    destination: Group {
                        if let recipe = recipe {
                            RecipeDetailView(recipe: recipe)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $showRecipeDetail,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    // MARK: - List Management
    
    private func addIngredientToList() {
        addToListAndClear(list: &ingredients, item: &newIngredient)
    }
    
    private func addDislikeToList() {
        addToListAndClear(list: &dislikes, item: &newDislike)
    }
    
    private func addToListAndClear(list: inout [String], item: inout String) {
        guard !item.isEmpty else { return }
        list.append(item)
        item = "" // Clear the input field after adding
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func deleteDislike(at offsets: IndexSet) {
        dislikes.remove(atOffsets: offsets)
    }
    
    // MARK: - Submission Logic
    
    private func submitData() {
        // Create the JSON payload from the ingredients and dislikes.
        let payload: [String: Any] = [
            "ingredients": ingredients,
            "dislikes": dislikes
        ]
        
        // Convert the payload dictionary to JSON data.
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("Error: Could not serialize data to JSON")
            return
        }
        
        // Instantiate the API configuration and client.
        let config = ApiConfig()
        let client = RestClient(apiConfig: config)
        
        // Call the REST client to make the POST request.
        // The endpoint "/submit" is just an example.
        client.postData(requestBody: jsonData) { result in
            switch result {
            case .success(let data):
                // Convert data to a string, then decode it into a Recipe.
                if let responseString = String(data: data, encoding: .utf8),
                   let decodedRecipe = Recipe.decodeRecipe(from: responseString) {
                    DispatchQueue.main.async {
                        self.recipe = decodedRecipe
                        self.showRecipeDetail = true
                    }
                } else {
                    print("Error: Failed to convert or decode data.")
                }
            case .failure(let error):
                print("Error submitting data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    GlobalStyledView {
        RecipeInputView()
    }
    .modelContainer(for: Item.self, inMemory: true)
}
