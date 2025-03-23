//
//  ApiClient.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//
import Foundation

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let config: ApiConfig
    
    init(session: URLSession = .shared, config: ApiConfig = .shared) {
        self.session = session
        self.config = config
    }
    
    func postData<T: Decodable>(endpoint: String, body: Encodable) async throws -> T {
        guard let url = URL(string: config.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        print("REST Request body: \(body)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
