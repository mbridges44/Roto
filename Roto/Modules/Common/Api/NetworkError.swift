//
//  NetworkErr.swift
//  Roto
//
//  Created by Michael Bridges on 2/19/25.
//

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unknown(Error)
}
