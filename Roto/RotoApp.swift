import SwiftUI
import SwiftData

@main
struct RecipeAIApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserProfile.self,
                FavoriteRecipe.self,
                SavedIngredient.self,
                SavedInstruction.self,
                Recipe.self,
                RecipeIngredient.self,
                Instruction.self
                
            )
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GlobalStyledView {
                MainTabView()
            }
        }
        .modelContainer(modelContainer)
    }
}
