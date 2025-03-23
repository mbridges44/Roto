//
//  ApiClientProtocol.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//

protocol APIClientProtocol {
    func postData<T: Decodable>(endpoint: String, body: Encodable) async throws -> T
}
