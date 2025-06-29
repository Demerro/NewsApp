//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 29.06.25.
//

import UIKit

final class ArticleViewModel {
    
    var onShowFullArticle: ((URL) -> Void)?
    
    let article: Article
    let imageDownloader: ImageDownloader
    
    init(article: Article, imageDownloader: ImageDownloader) {
        self.article = article
        self.imageDownloader = imageDownloader
    }
}

extension ArticleViewModel {
    
    func openFullNews() {
        onShowFullArticle?(article.url)
    }
}

extension ArticleViewModel {
    
    func loadImage(for url: URL) async -> UIImage? {
        return try? await imageDownloader.loadImage(for: url)
    }
}
