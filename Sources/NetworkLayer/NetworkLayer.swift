//
//  NetworkLayer.swift
//  Davaleba26
//
//  Created by Lika Nozadze on 11/19/23.

import UIKit

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

@available(iOS 13.0.0, *)


public final class NetworkManager {
    public static let shared = NetworkManager()
    
    private init() {}
    
    private func downloadData(fromURL urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    public  func fetchData<T: Decodable>(fromURL urlString: String) async throws -> T {
        do {
            let data = try await downloadData(fromURL: urlString)
            let decodedData: T = try await decodeData(with: data)
            return decodedData
        } catch {
            throw error
        }
    }
    private func decodeData<T: Decodable>(with data: Data) async throws -> T {
        do {
            let decoder = JSONDecoder()
            let actor = try decoder.decode(T.self, from: data)
            return actor
            
        } catch {
            throw NetworkError.invalidData
        }
    }
    
    public func fetchImage(fromURl urlString: String) async throws -> UIImage {
        do {
            let data = try await downloadData(fromURL: urlString)
            guard let image = UIImage(data: data) else {
                throw NetworkError.invalidData
            }
            return image
        } catch {
            throw error
        }
    }
}
