//
//  ArticleFactory.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.02.23.
//

import CoreData

class ArticleFactory {
    
    private let dataManager = DataStoreManager.shared
    
    func makeArticle(from jsonArticle: JSONArticle) -> Article? {
        if jsonArticle.urlToImage == nil {
            return nil
        }
        
        let article = Article(context: dataManager.persistentContainer.viewContext)
        
        article.setValue(jsonArticle.title, forKey: "title")
        article.setValue(jsonArticle.description, forKey: "articleDescription")
        article.setValue(jsonArticle.publishedAt, forKey: "publishedAt")
        article.setValue(jsonArticle.url, forKey: "url")
        article.setValue(jsonArticle.urlToImage, forKey: "urlToImage")
        article.setValue(jsonArticle.source.name, forKey: "sourceName")
        
        dataManager.saveContext()
        
        return article
    }
}
