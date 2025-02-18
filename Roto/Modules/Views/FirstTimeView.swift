import SwiftUI
import SwiftData

struct FirstTimeView: View {
    @Environment(\.appStyle) private var style
    @StateObject private var navigationVM = NavigationViewModel()
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    var body: some View {
        NavigationStack(path: $navigationVM.path) {
            VStack(spacing: 20) {
                Text("Welcome to Zest.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 90)
                    .foregroundColor(style.primaryColor)
                
                Text("Personalized recipes based on your pantry, preferences, and restrictions.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    .foregroundColor(style.primaryColor)
                
                // Two option cards
                VStack(spacing: 16) {
                    // Profile Setup Card
                    Button {
                        isFirstLaunch = false
                        navigationVM.navigateToProfileSetup()
                    } label: {
                        OptionCard(
                            title: "Profile Setup",
                            description: "Set up dietary restrictions and more",
                            systemImage: "person.circle.fill",
                            tintColor: style.primaryColor
                        )
                    }
                    
                    // Quick Recipe Creation Card
                    Button {
                        isFirstLaunch = false
                        navigationVM.navigateToRecipeCreate()
                    } label: {
                        OptionCard(
                            title: "Quick Create Recipe",
                            description: "Start creating recipes now",
                            systemImage: "fork.knife.circle.fill",
                            tintColor: style.accentColor
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()

            }
            .padding(24)
            .background(style.backgroundColor)
            .navigationDestination(for: AppDestination.self) { destination in
                NavigationRouter(destination: destination)
            }
        }.environmentObject(navigationVM)
    }
}

// Helper view for the option cards
private struct OptionCard: View {
    @Environment(\.appStyle) private var style

    let title: String
    let description: String
    let systemImage: String
    let tintColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundColor(tintColor)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(style.primaryColor)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(style.primaryColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1),
                       radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    GlobalStyledView {
        FirstTimeView()
    }
}
