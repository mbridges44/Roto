//
//  ApiClient.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//
import Foundation
import UIKit

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let config: ApiConfig
    private let deviceId: String
    
    init(session: URLSession = .shared, config: ApiConfig = .shared) {
        self.session = session
        self.config = config
        
        // Get or generate a persistent device identifier
        if let storedDeviceId = UserDefaults.standard.string(forKey: "app.roto.device.id") {
            self.deviceId = storedDeviceId
        } else {
            // Generate a new UUID for this device and store it
            let newDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            UserDefaults.standard.set(newDeviceId, forKey: "app.roto.device.id")
            self.deviceId = newDeviceId
        }
    }
    
    func postData<T: Decodable>(endpoint: String, body: Encodable) async throws -> T {
        guard let url = URL(string: config.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add tracing headers
        let requestId = UUID().uuidString
        request.setValue(requestId, forHTTPHeaderField: "X-Request-ID")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        
        request.httpBody = try? JSONEncoder().encode(body)
        print("REST Request body: \(body)")
        print("Tracing: Request ID: \(requestId), Device ID: \(deviceId)")
        
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
