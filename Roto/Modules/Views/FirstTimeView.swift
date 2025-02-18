import SwiftUI

struct FirstTimeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Zest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 90)
                    .foregroundColor(Color("BrandPrimary"))
                
                Text("Personalized pecipies based on your pantry, preferences, and restrictions.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    .foregroundColor(Color("BrandPrimary"))
                
                // Two horizontal buttons using HStack.
                HStack(spacing: 20) {
                    
                    NavigationLink(destination: RecipeInputView()) {
                        Text("Profile Setup")
                            .font(.headline)
                            .padding()
                            .background(Color("BrandPrimary"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RecipeInputView()) {
                        Text("Quick Create Recipe")
                            .font(.headline)
                            .padding()
                            .background(Color("BrandPrimary"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    

                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// Placeholder view for Quick Create Recipe.
struct QuickCreateRecipeView: View {
    var body: some View {
        VStack {
            Text("Quick Create Recipe View")
                .font(.title)
            // Add additional UI for quickly creating a recipe here.
        }
        .navigationTitle("Quick Recipe")
        .padding()
    }
}

// Placeholder view for Profile Setup.
struct ProfileSetupView: View {
    var body: some View {
        VStack {
            Text("Profile Setup View")
                .font(.title)
            // Add UI for setting up a user profile here.
        }
        .navigationTitle("Profile Setup")
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeView()
    }
}
