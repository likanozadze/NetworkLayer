//
//  NetworkLayer.swift
//  Davaleba26
//
//  Created by Lika Nozadze on 11/19/23.

import Foundation

enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case invalidData
    case decodingError(Error)
}

public final class NetworkManager {
    public static let shared = NetworkManager()
    
    // MARK: - Methods
    
    func request<T: Decodable>(baseURL: String, apiKey: String, endpoint: String, parameters: [String: Any], completion: @escaping (Result<T, NetworkError>) -> Void) {
         guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
             completion(.failure(.invalidURL))
             return
         }

         urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }

         guard let url = urlComponents.url else {
             completion(.failure(.invalidURL))
             return
         }

         var request = URLRequest(url: url)
         request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

         URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 completion(.failure(.networkError(error)))
                 return
             }

             guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                 completion(.failure(.invalidResponse))
                 return
             }

             guard let data = data else {
                 completion(.failure(.invalidData))
                 return
             }

             do {
                 let decodedData = try JSONDecoder().decode(T.self, from: data)
                 completion(.success(decodedData))
             } catch {
                 completion(.failure(.decodingError(error)))
             }
         }.resume()
     }
 }
