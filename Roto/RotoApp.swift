import SwiftUI
import SwiftData

@main
struct RecipeAIApp: App {
    let modelContainer: ModelContainer
    @State private var profileStateManager: ProfileStateManager!
    
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
                if let profileStateManager = profileStateManager {
                    MainTabView()
                        .environment(profileStateManager)
                } else {
                    // Show loading or placeholder while initializing
                    ProgressView()
                        .onAppear {
                            // Initialize once we have access to the ModelContext
                            let context = modelContainer.mainContext
                            profileStateManager = ProfileStateManager(modelContext: context)
                        }
                }
            }
        }
        .modelContainer(modelContainer)
    }
}
