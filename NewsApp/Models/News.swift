//
//  News.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

struct News: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Decodable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Decodable {
    let name: String
}
