//
//  ArticleFactory.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.02.23.
//

import Foundation

class ArticleFactory {
    
    private let dataStoreManager = DataStoreManager.shared
    
    func makeArticle(from jsonArticle: JSONArticle) -> Article {
        let article = Article(context: dataStoreManager.persistentContainer.viewContext)
        
        article.setValue(jsonArticle.title, forKey: "title")
        article.setValue(jsonArticle.description, forKey: "articleDescription")
        article.setValue(jsonArticle.publishedAt, forKey: "publishedAt")
        article.setValue(jsonArticle.url, forKey: "url")
        article.setValue(jsonArticle.urlToImage, forKey: "urlToImage")
        article.setValue(jsonArticle.source.name, forKey: "sourceName")
        
        return article
    }
}
