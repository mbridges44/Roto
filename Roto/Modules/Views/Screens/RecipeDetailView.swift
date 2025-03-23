import SwiftUI
import SwiftData

// MARK: - Title Section
struct RecipeTitleSection: View {
    let title: String
    let isFavorite: Bool
    let style: AppStyleConfig
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(style.titleFont)
                .foregroundColor(style.primaryColor)
            
            Spacer()
            
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isFavorite ? style.accentColor : style.primaryColor)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Description Section
struct RecipeDescriptionSection: View {
    let description: String?
    let timeEstimate: String?
    let style: AppStyleConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let description = description {
                Text(description)
                    .font(.body)
                    .foregroundColor(style.primaryColor)
            }
            
            if let timeEstimate = timeEstimate {
                TimeEstimateCard(timeEstimate: timeEstimate, style: style)
            }
        }
        .padding(.bottom, 8)
    }
}

struct TimeEstimateCard: View {
    let timeEstimate: String
    let style: AppStyleConfig
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .foregroundColor(style.accentColor)
            Text(timeEstimate)
                .font(.headline)
                .foregroundColor(style.primaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Ingredients Section
struct RecipeIngredientsSection: View {
    let ingredients: [SavedIngredient]
    let style: AppStyleConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "INGREDIENTS")
            
            VStack(spacing: 8) {
                ForEach(ingredients, id: \.name) { ingredient in
                    IngredientRow(ingredient: ingredient, style: style)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct IngredientRow: View {
    let ingredient: SavedIngredient
    let style: AppStyleConfig
    
    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.body)
                .foregroundColor(style.primaryColor)
            Spacer()
            Text(ingredient.quantity)
                .font(.body)
                .foregroundColor(style.primaryColor.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Instructions Section
struct RecipeInstructionsSection: View {
    let instructions: [Instruction]
    let style: AppStyleConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "INSTRUCTIONS")
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(instructions.sorted(by: { $0.order < $1.order })) { instruction in
                    InstructionRow(step: instruction.step,
                                 number: instruction.order + 1,
                                 style: style)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct InstructionRow: View {
    let step: String
    let number: Int
    let style: AppStyleConfig
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(style.accentColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(style.accentColor.opacity(0.1))
                )
            
            Text(step)
                .font(.body)
                .foregroundColor(style.primaryColor)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Main View
struct RecipeDetailView: View {
    @Environment(\.appStyle) private var style
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var navigationVM: NavigationViewModel
    @State private var favoritesManager: FavoritesManagerImpl?
    @State private var isFavorite = false
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.sectionSpacing) {
                RecipeTitleSection(
                    title: recipe.name,
                    isFavorite: isFavorite,
                    style: style,
                    onToggleFavorite: toggleFavorite
                )
                
                RecipeDescriptionSection(
                    description: recipe.recipeDescription,
                    timeEstimate: recipe.timeEstimate,
                    style: style
                )
                
                RecipeIngredientsSection(
                    ingredients: recipe.ingredients.map {
                        SavedIngredient(name: $0.name, quantity: $0.quantity)
                    },
                    style: style
                )
                
                RecipeInstructionsSection(
                    instructions: recipe.instructions,
                    style: style
                )
            }
            .padding(24)
        }
        .background(style.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupFavoritesManager()
        }
    }
    
    private func setupFavoritesManager() {
        favoritesManager = FavoritesManagerImpl(context: modelContext)
        isFavorite = favoritesManager?.isFavorite(recipe) ?? false
    }
    
    private func toggleFavorite() {
        favoritesManager?.toggleFavorite(recipe)
        isFavorite.toggle()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GlobalStyledView {
            RecipeDetailView(recipe: Recipe.mockRecipes[0])
        }
    }
    .modelContainer(for: [FavoriteRecipe.self, SavedIngredient.self, SavedInstruction.self], inMemory: true)
    .environmentObject(NavigationViewModel())
}
