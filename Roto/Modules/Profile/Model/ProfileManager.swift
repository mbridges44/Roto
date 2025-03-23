//
//  ProfileManager.swift
//  Roto
//
//  Created by Michael Bridges on 2/23/25.
//
import SwiftData
import Foundation

protocol ProfileManager {
    func saveProfile(_ profile: UserProfile)
    func loadProfile() -> UserProfile?
}
