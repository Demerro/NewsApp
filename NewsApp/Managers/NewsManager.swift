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
    
    func getTopHeadlines() async throws -> News {
        guard let url = URL(string: "\(K.baseURL)/top-headlines?country=us&apiKey=\(K.APIKey)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let topHeadlines = try JSONDecoder().decode(News.self, from: data)
        return topHeadlines
    }
}
