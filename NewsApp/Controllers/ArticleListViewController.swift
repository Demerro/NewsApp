//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

enum Section {
    case main
}

class ArticleListViewController: UIViewController {
    
    private let articleListView = ArticleListView()
    private var isPaginating = false
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Article>(
        collectionView: articleListView.collectionView
    ) { collectionView, indexPath, article in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListViewCell.identifier, for: indexPath) as! ArticleListViewCell
        
        cell.configure(with: article)
        
        return cell
    }
    
    override func loadView() {
        view = articleListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleListView.collectionView.delegate = self
        
        setupPullToRefresh()
        
        refreshNews()
    }
    
    private func refreshNews() {
        Task {
            updateDataSource(with: await fetchArticles())
            
            articleListView.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func addNews() {
        Task {
            let articles = await fetchArticles()
            var snapshot = dataSource.snapshot(for: .main)
            snapshot.append(articles)
            
            isPaginating = false
        }
    }
    
    private func fetchArticles() async -> [Article] {
        isPaginating = true
        
        let newsManager = NewsManager.shared
        
        do {
            let topic = ["crime", "bitcoin", "war", "finance", "politics", "weather"].randomElement()!
            let articles = try await newsManager.getNews(about: topic).articles
            
            isPaginating = false
            return articles
        } catch let NetworkError.clientOrTransport(error) {
            showAlert(message: "Client or transport error occurred.")
            dump(error)
        } catch let NetworkError.clientOrTransportSpecific(urlError) {
            showAlert(message: urlError.localizedDescription)
            dump(urlError)
        } catch let NetworkError.server(response) {
            showAlert(message: "Server error occurred.")
            dump(response)
        } catch NetworkError.invalidURL {
            showAlert(message: "Invalid URL used to fetch news.")
            dump("Invalid URL")
        } catch NetworkError.noData {
            showAlert(message: "Can't parse server response.")
            dump("No data")
        } catch NetworkError.unknown {
            showAlert(message: "Unknown error occurred.")
            dump("Unknown error")
        } catch {
            showAlert(message: error.localizedDescription)
            dump(error)
        }
        
        isPaginating = false
        return []
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.refreshNews()
        }, for: .valueChanged)
        
        articleListView.collectionView.refreshControl = refreshControl
    }
    
    private func updateDataSource(with articles: [Article]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
        snapshot.appendSections([.main])
        snapshot.appendItems(articles, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
