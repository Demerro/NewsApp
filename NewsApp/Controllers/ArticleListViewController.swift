//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit
import CoreData

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
        
        loadNews()
    }
    
    @objc private func fetchNews() {
        let newsManager = NewsManager.shared
        let dataStoreManager = DataStoreManager.shared
        
        let articleFactory = ArticleFactory(objectContext: dataStoreManager.persistentContainer.viewContext)
        
        Task {
            do {
                let news = try await newsManager.getTopHeadlines()
                articles = news.articles.map {
                    articleFactory.makeArticle(from: $0)
                }
                
                articleListView.collectionView.reloadData()
                articleListView.collectionView.refreshControl?.endRefreshing()
                
                dataStoreManager.saveContext()
            } catch {
                print(error)
            }
        }
    }
    
    private func loadNews() {
        let dataStoreManager = DataStoreManager.shared
        let model = dataStoreManager.persistentContainer.managedObjectModel
        let context = dataStoreManager.persistentContainer.viewContext
        let fetchRequest = model.fetchRequestTemplate(forName: "AllArticles")!
        
        do {
            articles = try context.fetch(fetchRequest).compactMap {
                guard let article = $0 as? Article else { return nil }
                return article
            }
            
            articleListView.collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchNews), for: .valueChanged)
        articleListView.collectionView.refreshControl = refreshControl
    }
    
    private func increaseViews(at path: IndexPath) {
        let dataStoreManager = DataStoreManager.shared
        
        articles[path.row].views += 1
        dataStoreManager.saveContext()
    }
}

extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListViewCell.identifier, for: indexPath) as! ArticleListViewCell
        let article = articles[indexPath.row]
        
        cell.articleImageView.setImage(url: URL(string: article.urlToImage!))
        cell.articleTitle.text = article.title
        cell.watchCounter.text = "\(article.views) views"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let viewController = ArticleViewController(article: articles[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
        
        increaseViews(at: indexPath)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension ArticleListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}
