//
//  NetworkLayer.swift
//  Davaleba26
//
//  Created by Lika Nozadze on 11/19/23.

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidData
}

public final class NetworkManager {
    public static let shared = NetworkManager()
    
    // MARK: - Methods
    
    public func fetchData<T: Decodable>(with urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.invalidData))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let dataResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dataResponse))
                }
            } catch {
                completion(.failure(.invalidData))
            }
        }.resume()
    }
}
