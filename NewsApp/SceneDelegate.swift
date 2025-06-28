//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let articlesStorageClient = ArticlesStorageClient()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        let viewModel = ArticleListViewModel(articlesStorageClient: articlesStorageClient, newsClient: NewsClient())
        let articleListViewController = ArticleListViewController(viewModel: viewModel)
        articlesStorageClient.dataProvider = viewModel
        window.rootViewController = UINavigationController(rootViewController: articleListViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        articlesStorageClient.saveArticlesSubject.send(Void())
    }
}
