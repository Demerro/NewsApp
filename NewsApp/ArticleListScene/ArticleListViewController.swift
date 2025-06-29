//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit
import Combine

final class ArticleListViewController: UIViewController {
    
    private lazy var dataSource = makeDiffableDataSource()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let articleCollectionView: UICollectionView = {
        $0.delaysContentTouches = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))
    
    let viewModel: ArticleListViewModel
    
    init(viewModel: ArticleListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = articleCollectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommon()
        binding()
        viewModel.restoreCacheArticles()
        viewModel.refreshNews()
    }
}

extension ArticleListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let article = viewModel.articles[indexPath.item]
        let viewController = ArticleViewController(article: article)
        navigationController?.pushViewController(viewController, animated: true)
        viewModel.incrementWatchCounter(for: article.url)
        reconfigureItems([article.id])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewPosition = articleCollectionView.contentSize.height - scrollView.frame.height - 200
        
        if position > collectionViewPosition {
            viewModel.appendNews()
        }
    }
}

extension ArticleListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}

extension ArticleListViewController {
    
    private func makeCellRegistration() -> CellRegistration {
        CellRegistration { [unowned self] cell, indexPath, itemIdentifier in
            cell.itemIdentifier = itemIdentifier
            let article = viewModel.articles[indexPath.item]
            var configuration = ArticleListViewCell<Item>.Configuration()
            configuration.text = article.title
            configuration.watchCounter = article.watchCounter
            if let image = article.image {
                configuration.image = image
                cell.apply(configuration: configuration)
            } else {
                cell.apply(configuration: configuration)
                Task {
                    configuration.image = await viewModel.loadImage(for: indexPath.item)
                    cell.apply(configuration: configuration)
                }
            }
        }
    }
    
    private func makeDiffableDataSource() -> DataSource {
        let cellRegistration = makeCellRegistration()
        return DataSource(collectionView: articleCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func updateDataSource(with items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
    
    private func reconfigureItems(_ items: [Item]) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(items)
        dataSource.apply(snapshot)
    }
}

extension ArticleListViewController {
    
    private func setupCommon() {
        title = "Articles"
        articleCollectionView.delegate = self
        articleCollectionView.prefetchDataSource = self
    }
    
    private func showAlert(message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
}

extension ArticleListViewController {
    
    private func binding() {
        let refreshControl = UIRefreshControl()
        articleCollectionView.refreshControl = refreshControl
        refreshControl.publisher(forEvent: .valueChanged)
            .sink { [viewModel] in
                viewModel.refreshNews()
            }
            .store(in: &cancellables)
        
        viewModel.articlesSubject
            .sink { [weak self] _ in
                guard let self else { return }
                refreshControl.endRefreshing()
                updateDataSource(with: viewModel.articles.map(\.id))
            }
            .store(in: &cancellables)
        
        viewModel.errorMessageSubject
            .dropFirst()
            .sink { [weak self] in
                guard let self else { return }
                refreshControl.endRefreshing()
                showAlert(message: $0)
            }
            .store(in: &cancellables)
    }
}

extension ArticleListViewController {
    
    private enum Section {
        case main
    }
    
    private typealias Item = UUID
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private typealias CellRegistration = UICollectionView.CellRegistration<ArticleListViewCell<Item>, Item>
}

extension ArticleListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            Task { await viewModel.loadImage(for: indexPath.item) }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            viewModel.cancelImageLoading(for: indexPath.item)
        }
    }
}
