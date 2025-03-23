//
//  GenerateRecipePayload.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//
struct GenerateRecipePayload: Encodable {
    let ingredients: [String]
    let dislikes: [String]
}
