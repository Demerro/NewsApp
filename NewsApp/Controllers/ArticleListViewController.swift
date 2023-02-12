//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

class ArticleListViewController: UIViewController {
    
    private let articleListView = ArticleListView()
    private var articles = [Article]()
    
    override func loadView() {
        view = articleListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleListView.collectionView.delegate = self
        articleListView.collectionView.dataSource = self
        
        setupPullToRefresh()
        
        fetchNews()
    }
    
    @objc private func fetchNews() {
        let newsManager = NewsManager.shared
        
        Task {
            do {
                articles = try await newsManager.getTopHeadlines().articles.compactMap {
                    if $0.urlToImage == nil {
                        return nil
                    }
                    
                    return $0
                }
                
                articleListView.collectionView.reloadData()
                articleListView.collectionView.refreshControl?.endRefreshing()
            } catch {
                print(error)
            }
        }
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchNews), for: .valueChanged)
        articleListView.collectionView.refreshControl = refreshControl
    }
}

extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListViewCell.identifier, for: indexPath) as! ArticleListViewCell
        
        cell.configure(with: articles[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let viewController = ArticleViewController(article: articles[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ArticleListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}
