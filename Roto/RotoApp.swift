import SwiftData
import SwiftUI

@main
struct RotoApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true

    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            UserProfile.self,  // Add UserProfile to the schema
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Global background color (covers the entire screen)
                Color("BrandBackground")
                    .ignoresSafeArea()
                if isFirstLaunch {
                    FirstTimeView()
                } else {
                    FirstTimeView()  // You'll need to create this view
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
