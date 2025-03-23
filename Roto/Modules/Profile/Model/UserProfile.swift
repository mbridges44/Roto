// Fix for UserProfile.swift

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
            // Skip empty strings that might occur from splitting
            return baseIngredientsString.isEmpty ? [] :
                baseIngredientsString.split(separator: ",", omittingEmptySubsequences: true)
                    .map { unescapeCommas(String($0)) }
                    .filter { !$0.isEmpty }
        }
        set {
            // Filter out empty strings before joining
            baseIngredientsString = newValue
                .filter { !$0.isEmpty }
                .map { escapeCommas($0) }
                .joined(separator: ",")
        }
    }
    
    var dislikes: [String] {
        get {
            // Skip empty strings that might occur from splitting
            return dislikesString.isEmpty ? [] :
                dislikesString.split(separator: ",", omittingEmptySubsequences: true)
                    .map { unescapeCommas(String($0)) }
                    .filter { !$0.isEmpty }
        }
        set {
            // Filter out empty strings before joining
            dislikesString = newValue
                .filter { !$0.isEmpty }
                .map { escapeCommas($0) }
                .joined(separator: ",")
        }
    }
    
    var dietCategories: [DietCategoriesEnum] {
        get {
            dietCategoriesString.isEmpty ? [] :
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
        // Filter out any empty strings before storing
        self.baseIngredientsString = baseIngredients
            .filter { !$0.isEmpty }
            .map { $0.replacingOccurrences(of: ",", with: "\\,") }
            .joined(separator: ",")
        
        self.dislikesString = dislikes
            .filter { !$0.isEmpty }
            .map { $0.replacingOccurrences(of: ",", with: "\\,") }
            .joined(separator: ",")
        
        self.dietCategoriesString = dietCategories
            .map { $0.rawValue }
            .joined(separator: ",")
    }
}
