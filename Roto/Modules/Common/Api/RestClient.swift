import Foundation
//
//  RestClient.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
/// REST Client struct for making API requests.
struct RestClient {
    
    private let session: URLSession
    private let config: ApiConfig
    
    init(session: URLSession = .shared, apiConfig: ApiConfig) {
        self.session = session
        self.config = apiConfig
    }
        
    func postData(requestBody: Data, completion: @escaping (Result<Data, Error>) -> Void) {
            // Combine the base URL from the config with the endpoint.
            guard let url = URL(string: config.baseURL) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
                return
            }
            
            // Create a URLRequest and set its method to POST.
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = requestBody
            
            // Set the Content-Type header (commonly application/json for JSON requests).
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a data task to send the request.
            let task = session.dataTask(with: request) { data, response, error in
                // If there's an error, return it via the completion handler.
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Ensure the response is an HTTPURLResponse and check the status code.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                    return
                }
                
                // If data is received, return it via the completion handler.
                if let data = data {
                    completion(.success(data))
                }
            }
            
            // Start the network request.
            task.resume()
        }
}
