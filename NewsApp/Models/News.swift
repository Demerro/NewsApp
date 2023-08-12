//
//  News.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation

struct News: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Decodable, Hashable, Identifiable {
    var id = UUID()
    let source: Source
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case source = "source"
        case title = "title"
        case description = "description"
        case url = "url"
        case urlToImage = "urlToImage"
        case publishedAt = "publishedAt"
    }
}

struct Source: Decodable, Hashable {
    let name: String
}
