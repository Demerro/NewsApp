//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit

class ArticleViewController: UIViewController {
    
    private let articleView = ArticleView()
    private var currentArticle: Article?
    
    init(article: Article) {
        currentArticle = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = articleView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureArticle()
    }
    
    func configureArticle() {
        guard let article = currentArticle else { fatalError("Article can't be nil, but nil found.") }
        
        if let urlString = article.urlToImage,
           let url = URL(string: urlString) {
            articleView.articleImageView.setImage(url: url)
        }
        
        articleView.articleTitle.text = article.title
        articleView.articleDescription.text = article.description
        articleView.articleSource.text = "- \(article.source.name)"
        
        let date = ISO8601DateFormatter().date(from: article.publishedAt)!
        articleView.articleDate.text = "\(date.description(with: .current))"
        
        articleView.fullTextButton.setTitle(article.url, for: .normal)
        articleView.fullTextButton.addAction(UIAction { [weak self] _ in
            self?.openFullNews()
        }, for: .touchUpInside)
    }
    
    private func openFullNews() {
        guard let articleURL = currentArticle?.url,
              let url = URL(string: articleURL)
        else {
            assertionFailure("Article URL is nil. Unable to open the full text of the news.")
            return
        }
        let viewController = ArticleTextViewController(articleURL: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
