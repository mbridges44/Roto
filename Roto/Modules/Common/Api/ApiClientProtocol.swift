//
//  ApiClientProtocol.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//

protocol APIClientProtocol {
    /// Posts data to the specified endpoint with tracing headers
    /// - Parameters:
    ///   - endpoint: The API endpoint path to post to
    ///   - body: The encodable body to send
    /// - Returns: Decoded response of type T
    /// - Throws: NetworkError if request fails
    func postData<T: Decodable>(endpoint: String, body: Encodable) async throws -> T
}
