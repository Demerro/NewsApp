//
//  AppDependencyContainer.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 29.06.25.
//

final class AppDependencyContainer {
    lazy var newsClient = NewsClient()
    lazy var articlesStorageClient = ArticlesStorageClient()
    lazy var imageDownloader = ImageDownloader()
    
    func makeCoordinator() -> AppCoordinator {
        AppCoordinator(dependencyContainer: self)
    }
}
