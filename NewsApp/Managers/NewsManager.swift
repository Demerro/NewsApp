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
    
    func getNews(about keywords: String) async throws -> News {
        guard let url = URL(string: "\(K.baseURL)/everything?q=\(keywords)&pageSize=20&apiKey=\(K.APIKey)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let news = try JSONDecoder().decode(News.self, from: data)
        
        return news
    }
}
