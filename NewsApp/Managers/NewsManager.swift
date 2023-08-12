//
//  NewsManager.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation

class NewsManager {
    static let shared = NewsManager()
    
    private init() { }
    
    func getNews(about keyword: String) async throws -> News {
        let urlComponents = URLComponents(string: keyword)!
        let data = try await getData(urlComponents: urlComponents)
        
        return try JSONDecoder().decode(News.self, from: data)
    }
    
    private func getData(urlComponents: URLComponents) async throws -> Data {
        guard let url = URL(string: "\(K.baseURL)/everything?q=\(urlComponents.string ?? "")&pageSize=20&apiKey=\(K.APIKey)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response): (Data?, URLResponse?)
        
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            if let urlError = error as? URLError {
                throw NetworkError.clientOrTransportSpecific(urlError)
            } else {
                throw NetworkError.clientOrTransport(error)
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.server(httpResponse)
        }
        
        guard let data else {
            throw NetworkError.noData
        }
        
        return data
    }
}
