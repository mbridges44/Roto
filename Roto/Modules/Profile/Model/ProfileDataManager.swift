// Fix for ProfileDataManager.swift

import SwiftData
import Foundation

final class ProfileDataManager : ProfileManager {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveProfile(_ profile: UserProfile) {
        // First, remove any existing profiles
        clearExistingProfiles()
        
        // Then insert the new profile
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
        do {
            let profiles = try context.fetch(fetchDescriptor)
            if !profiles.isEmpty {
                print("ProfileDataManager - Found \(profiles.count) profiles, returning first")
                return profiles.first
            } else {
                print("ProfileDataManager - No profiles found")
            }
        } catch {
            print("ProfileDataManager - Error fetching profiles: \(error)")
        }
        return nil
    }
    
    private func clearExistingProfiles() {
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: nil)
        do {
            let existingProfiles = try context.fetch(fetchDescriptor)
            for profile in existingProfiles {
                context.delete(profile)
            }
            if !existingProfiles.isEmpty {
                print("Deleted \(existingProfiles.count) existing profiles")
            }
        } catch {
            print("Error clearing existing profiles: \(error)")
        }
    }
}
