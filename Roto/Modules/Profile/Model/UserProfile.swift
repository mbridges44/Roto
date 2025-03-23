import SwiftData
import Foundation

@Model
final class UserProfile: Identifiable {
    var id: UUID = UUID()
    // Provide empty string defaults
    var baseIngredientsString: String = ""
    var dislikesString: String = ""
    var dietCategoriesString: String = ""
    
    // Helper methods for escaping/unescaping commas
    private func escapeCommas(_ string: String) -> String {
        return string.replacingOccurrences(of: ",", with: "\\,")
    }
    
    private func unescapeCommas(_ string: String) -> String {
        return string.replacingOccurrences(of: "\\,", with: ",")
    }
    
    // Array handling with comma escaping
    var baseIngredients: [String] {
        get {
            baseIngredientsString.split(separator: ",", omittingEmptySubsequences: false)
                .map { unescapeCommas(String($0)) }
        }
        set {
            baseIngredientsString = newValue
                .map { escapeCommas($0) }
                .joined(separator: ",")
        }
    }
    
    var dislikes: [String] {
        get {
            dislikesString.split(separator: ",", omittingEmptySubsequences: false)
                .map { unescapeCommas(String($0)) }
        }
        set {
            dislikesString = newValue
                .map { escapeCommas($0) }
                .joined(separator: ",")
        }
    }
    
    var dietCategories: [DietCategoriesEnum] {
        get {
            dietCategoriesString.split(separator: ",")
                .compactMap { DietCategoriesEnum(rawValue: String($0)) }
        }
        set {
            dietCategoriesString = newValue
                .map { $0.rawValue }
                .joined(separator: ",")
        }
    }
    
    init(baseIngredients: [String] = [], dislikes: [String] = [], dietCategories: [DietCategoriesEnum] = []) {
        self.baseIngredientsString = baseIngredients
            .map { $0.replacingOccurrences(of: ",", with: "\\,") }
            .joined(separator: ",")
        self.dislikesString = dislikes
            .map { $0.replacingOccurrences(of: ",", with: "\\,") }
            .joined(separator: ",")
        self.dietCategoriesString = dietCategories
            .map { $0.rawValue }
            .joined(separator: ",")
    }
}
