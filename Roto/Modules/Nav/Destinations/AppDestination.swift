//
//  AppDestination.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
// AppDestination.swift
enum AppDestination: Hashable {
    case main(MainDestination)
    case profile(ProfileDestination)
    case recipe(RecipeDestination)
}
