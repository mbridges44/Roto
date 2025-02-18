//
//  DietCategoriesEnum.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
import SwiftData
import Foundation

enum DietCategoriesEnum: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case VEGAN = "Vegan"
    case VEGETARIAN = "Vegetarian"
    case PESCATARIAN = "Pescatarian"
    case GLUTEN_FREE = "Gluten Free"
    case KOSHER = "Kosher"
    
    func encode(with coder: NSCoder) {
        coder.encode(self.rawValue, forKey: "value")
    }
    
    init?(coder: NSCoder) {
        if let value = coder.decodeObject(forKey: "value") as? String,
           let category = DietCategoriesEnum(rawValue: value) {
            self = category
        } else {
            return nil
        }
    }
}
