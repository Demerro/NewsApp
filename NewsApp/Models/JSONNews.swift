//
//  JSONNews.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

struct JSONNews: Decodable {
    let status: String
    let totalResults: Int
    let articles: [JSONArticle]
}

struct JSONArticle: Decodable {
    let source: JSONSource
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct JSONSource: Decodable {
    let name: String
}
