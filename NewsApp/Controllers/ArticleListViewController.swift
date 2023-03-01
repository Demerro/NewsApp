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
    private var isPaginating = false
    
    override func loadView() {
        view = articleListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleListView.collectionView.delegate = self
        articleListView.collectionView.dataSource = self
        
        setupPullToRefresh()
        
        loadNews()
        refreshNews()
    }
    
    @objc private func refreshNews() {
        Task {
            articles = await fetchArticles()
            
            articleListView.collectionView.reloadData()
            articleListView.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func addNews() {
        Task {
            articles += await fetchArticles()
            
            articleListView.collectionView.reloadData()
            isPaginating = false
        }
    }
    
    private func fetchArticles() async -> [Article] {
        isPaginating = true
        
        let newsManager = NewsManager.shared
        let context = DataStoreManager.shared.persistentContainer.viewContext
        let articleFactory = ArticleFactory(objectContext: context)
        
        do {
            let topic = ["crime", "bitcoin", "war", "finance", "politics"].randomElement()!
            let articles = try await newsManager.getNews(about: topic).articles.compactMap {
                articleFactory.makeArticle(from: $0)
            }
            
            isPaginating = false
            return articles
        } catch {
            print("Error when fetching data from API: \(error)")
        }
        
        isPaginating = false
        return []
    }
    
    private func loadNews() {
        let dataStoreManager = DataStoreManager.shared
        let model = dataStoreManager.persistentContainer.managedObjectModel
        let context = dataStoreManager.persistentContainer.viewContext
        let fetchRequest = model.fetchRequestTemplate(forName: "AllArticles")!
        
        do {
            articles = try context.fetch(fetchRequest).map { $0 as! Article }
            
            articleListView.collectionView.reloadData()
        } catch {
            print("Error when loading data from database: \(error)")
        }
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isPaginating else { return }
        
        let position = scrollView.contentOffset.y
        let collectionViewPosition = articleListView.collectionView.contentSize.height - scrollView.frame.height - 100
        
        if position > collectionViewPosition {
            addNews()
        }
    }
}

extension ArticleListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}
