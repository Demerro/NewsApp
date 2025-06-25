//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit
import Combine

final class ArticleListViewController: UIViewController {
    
    private let viewModel = ArticleListViewModel()
    
    private lazy var dataSource = makeDiffableDataSource()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let articleCollectionView: UICollectionView = {
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))
    
    override func loadView() {
        view = articleCollectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommon()
        binding()
    }
}

extension ArticleListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let viewController = ArticleViewController(article: viewModel.articles[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewPosition = articleCollectionView.contentSize.height - scrollView.frame.height - 100
        
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
        CellRegistration { [viewModel] cell, indexPath, itemIdentifier in
            cell.configure(with: viewModel.articlesStorage[indexPath.row])
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
}

extension ArticleListViewController {
    
    private func setupCommon() {
        title = "Articles"
        articleCollectionView.delegate = self
        articleCollectionView.dataSource = dataSource
    }
    
    private func showAlert(message: String) {
        guard presentingViewController == nil else { return }
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
            .sink { [viewModel] in viewModel.refreshNews() }
            .store(in: &cancellables)
        
        viewModel.$articles
            .sink { [weak self] in
                refreshControl.endRefreshing()
                self?.updateDataSource(with: $0.map(\.id))
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] in
                refreshControl.endRefreshing()
                self?.showAlert(message: $0)
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
    
    private typealias CellRegistration = UICollectionView.CellRegistration<ArticleListViewCell, Item>
}
