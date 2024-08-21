//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit
import Combine

private enum Section {
    case main
}

final class ArticleListViewController: UIViewController {
    
    private let articleListView = ArticleListView()
    private let viewModel = ArticleListViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Article>!
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        view = articleListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Articles"
        articleListView.collectionView.delegate = self
        setupDataSource()
        binding()
    }
    
    private func setupDataSource() {
        dataSource = .init(collectionView: articleListView.collectionView, cellProvider: { collectionView, indexPath, article in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListViewCell.identifier, for: indexPath) as! ArticleListViewCell
            
            cell.configure(with: article)
            
            return cell
        })
    }
    
    private func binding() {
        let refreshControl = UIRefreshControl()
        articleListView.collectionView.refreshControl = refreshControl
        refreshControl.publisher(forEvent: .valueChanged)
            .sink { [viewModel] in viewModel.refreshNews() }
            .store(in: &cancellables)
        
        viewModel.$articles
            .sink { [weak self] in 
                self?.updateDataSource(with: $0)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .sink { [weak self] in
                if $0 != nil { self?.showAlert(message: $0!) }
            }
            .store(in: &cancellables)
    }
    
    private func updateDataSource(with articles: [Article]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
        snapshot.appendSections([.main])
        snapshot.appendItems(articles)
        dataSource.apply(snapshot)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
}

extension ArticleListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let article = dataSource.snapshot(for: .main).items[indexPath.row]
        let viewController = ArticleViewController(article: article)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewPosition = articleListView.collectionView.contentSize.height - scrollView.frame.height - 100
        
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
