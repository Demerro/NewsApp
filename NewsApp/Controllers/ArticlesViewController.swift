//
//  ArticlesViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

class ArticlesViewController: UIViewController {
    
    private let newsView = ArticlesView()
    private var viewModels = [ArticleViewModel]()
    
    override func loadView() {
        view = newsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsView.collectionView.delegate = self
        newsView.collectionView.dataSource = self
        
        fetchNews()
    }
    
    func fetchNews() {
        let newsManager = NewsManager.shared
        
        Task {
            do {
                viewModels = try await newsManager.getTopHeadlines().articles.compactMap {
                    guard let urlToImage = $0.urlToImage else { return nil }
                    
                    return ArticleViewModel(
                        title: $0.title, imageURL: URL(string: urlToImage), watchCount: 2
                    )
                }
                
                newsView.collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

extension ArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleViewCell.identifier, for: indexPath) as! ArticleViewCell
        
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }
}

extension ArticlesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}
