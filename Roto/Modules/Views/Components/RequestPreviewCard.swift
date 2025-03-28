import SwiftUI

struct RequestPreviewCard: View {
    @Environment(\.appStyle) private var style
    
    let ingredientsFromProfile: [String]
    let ingredientsFromGenerator: [String]
    let dislikesFromProfile: [String]
    let notes: String
    
    init(
        ingredientsFromProfile: [String] = [],
        ingredientsFromGenerator: [String] = [],
        dislikesFromProfile: [String] = [],
        notes: String = ""
    ) {
        self.ingredientsFromProfile = ingredientsFromProfile
        self.ingredientsFromGenerator = ingredientsFromGenerator
        self.dislikesFromProfile = dislikesFromProfile
        self.notes = notes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("Your Recipe Request")
                .font(.headline)
                .foregroundColor(style.primaryColor)
            
            // Profile Summary
            VStack(alignment: .leading, spacing: 8) {
                // Current count
                HStack(spacing: 6) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(style.accentColor)
                        .imageScale(.small)
                    
                    Text("\(ingredientsFromGenerator.count) ingredients added to request")
                        .font(.caption)
                        .foregroundColor(style.primaryColor)
                }
                
                // Special requests section
                if !notes.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "note.text")
                            .foregroundColor(style.accentColor)
                            .imageScale(.small)
                        
                        Text("Request: \(notes)")
                            .font(.caption)
                            .foregroundColor(style.primaryColor)
                    }
                }
                
                // Profile section - always show this section for consistent height
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("From Your Profile")
                        .font(.caption)
                        .foregroundColor(style.primaryColor.opacity(0.7))
                    
                    // Profile ingredients counter
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(style.accentColor)
                            .imageScale(.small)
                        
                        if ingredientsFromProfile.isEmpty {
                            Text("No pantry ingredients")
                                .font(.caption)
                                .foregroundColor(style.primaryColor.opacity(0.5))
                        } else {
                            Text("\(ingredientsFromProfile.count) pantry ingredients")
                                .font(.caption)
                                .foregroundColor(style.primaryColor)
                        }
                    }
                    
                    // Profile exclusions counter
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(style.accentColor)
                            .imageScale(.small)
                        
                        if dislikesFromProfile.isEmpty {
                            Text("No exclusions")
                                .font(.caption)
                                .foregroundColor(style.primaryColor.opacity(0.5))
                        } else {
                            Text("\(dislikesFromProfile.count) food exclusions")
                                .font(.caption)
                                .foregroundColor(style.primaryColor)
                        }
                    }
                }
                .opacity(ingredientsFromProfile.isEmpty && dislikesFromProfile.isEmpty ? 0.5 : 1.0)
            }
        }
        .padding(16)
        .frame(maxHeight: notes.isEmpty ? 180 : 200) // Adjust height based on notes
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Preview Extension
struct RequestPreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Empty state
            RequestPreviewCard()
                .padding()
            
            // With just current ingredients
            RequestPreviewCard(
                ingredientsFromGenerator: ["Chicken", "Onions", "Garlic"]
            )
            .padding()
            
            // With profile data and notes
            RequestPreviewCard(
                ingredientsFromProfile: ["Eggs", "Milk", "Flour", "Salt", "Pepper"],
                ingredientsFromGenerator: ["Chicken", "Onions"],
                dislikesFromProfile: ["Nuts", "Shellfish"],
                notes: "Use slow cooker"
            )
            .padding()
        }
        .background(Color("BrandBackground"))
    }
}
