//
//  News.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation

struct News: Decodable {
    let articles: [Article]
}

struct Article {
    let id = UUID()
    let source: String
    let title: String
    let description: String
    let url: URL?
    let urlToImage: URL?
    let publishedDate: Date
}

extension Article: Decodable {
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .source).decode(String.self, forKey: .name)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        url = try container.decode(URL.self, forKey: .url)
        urlToImage = try container.decode(URL.self, forKey: .urlToImage)
        publishedDate = try container.decode(Date.self, forKey: .publishedAt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case source
        case name
        case title
        case description
        case url
        case urlToImage
        case publishedAt
    }
}

extension Article: CustomStringConvertible {
}

extension Article: Hashable {
}

extension Article: Identifiable {
}
