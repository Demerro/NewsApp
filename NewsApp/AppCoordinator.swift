//
//  AppCoordinator.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 29.06.25.
//

import UIKit
import SafariServices

final class AppCoordinator {
    
    private let navigationController: UINavigationController
    private let dependencyContainer: AppDependencyContainer
    
    init(dependencyContainer: AppDependencyContainer) {
        let viewModel = ArticleListViewModel(
            articlesStorageClient: dependencyContainer.articlesStorageClient,
            newsClient: dependencyContainer.newsClient,
            imageDownloader: dependencyContainer.imageDownloader
        )
        let viewController = ArticleListViewController(viewModel: viewModel)
        dependencyContainer.articlesStorageClient.dataProvider = viewModel
        self.navigationController = UINavigationController(rootViewController: viewController)
        self.dependencyContainer = dependencyContainer
        viewModel.onShowArticle = { [unowned self] in
            showArticleScene(article: $0)
        }
    }
}

extension AppCoordinator {
    
    var rootViewController: UIViewController {
        navigationController
    }
}

extension AppCoordinator {
    
    private func showArticleScene(article: Article) {
        let viewModel = ArticleViewModel(article: article, imageDownloader: dependencyContainer.imageDownloader)
        let viewController = ArticleViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        viewModel.onShowFullArticle = { [unowned self] in
            showFullArticleScene(url: $0)
        }
    }
    
    private func showFullArticleScene(url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.preferredControlTintColor = .tintColor
        navigationController.present(viewController, animated: true)
    }
}
