//
//  ProfileDataManager.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
import SwiftData
import Foundation

final class ProfileDataManager {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveProfile(_ profile: UserProfile) {
        context.insert(profile)
        do {
            try context.save()
            print("Profile saved successfully!")
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
    
    func loadProfile() -> UserProfile? {
        // Example fetch: assume there is only one profile.
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: nil)
        if let profiles = try? context.fetch(fetchDescriptor), !profiles.isEmpty {
            return profiles.first
        }
        return nil
    }
}

