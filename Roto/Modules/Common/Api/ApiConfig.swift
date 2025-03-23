//
//  ApiConfig.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//

/// Configuration struct to store the API endpoint.
struct ApiConfig {
    static let shared = ApiConfig() // Singleton-like access.
    let baseURL: String
    
    init() {
        self.baseURL = "https://us-central1-recipe-ai-451017.cloudfunctions.net/function-1"
    }
}
