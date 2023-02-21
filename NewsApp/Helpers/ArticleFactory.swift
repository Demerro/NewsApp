//
//  ArticleFactory.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.02.23.
//

import CoreData

class ArticleFactory {
    
    let context: NSManagedObjectContext
    
    init(objectContext: NSManagedObjectContext) {
        context = objectContext
    }
    
    func makeArticle(from jsonArticle: JSONArticle) -> Article {
        let article = Article(context: context)
        
        article.setValue(jsonArticle.title, forKey: "title")
        article.setValue(jsonArticle.description, forKey: "articleDescription")
        article.setValue(jsonArticle.publishedAt, forKey: "publishedAt")
        article.setValue(jsonArticle.url, forKey: "url")
        article.setValue(jsonArticle.urlToImage, forKey: "urlToImage")
        article.setValue(jsonArticle.source.name, forKey: "sourceName")
        
        return article
    }
}
