//
//  NetworkLayer.swift
//  Davaleba26
//
//  Created by Lika Nozadze on 11/19/23.

import Foundation

public final class NetworkManager {
    public static let shared = NetworkManager()
    
    //MARK: - Methods
    public func fetchData<T: Decodable>(with URLString: String, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard !URLString.isEmpty, let URL = URL(string: URLString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: URL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let dataResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dataResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
