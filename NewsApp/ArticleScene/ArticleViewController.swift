//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit

final class ArticleViewController: UIViewController {
    
    private let articleScrollView = ArticleScrollView()
    private var article: Article?
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = articleScrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        articleScrollView.textView.delegate = self
        configureArticle()
    }
}

extension ArticleViewController {
    
    private func openFullNews() {
        guard let url = article?.url else {
            assertionFailure("Article URL is nil. Unable to open the full text of the news.")
            return
        }
        let viewController = ArticleTextViewController(articleURL: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func configureArticle() {
        guard let article else { preconditionFailure("Article can't be nil, but nil found.") }
        
        if let url = article.urlToImage {
            articleScrollView.articleImageView.setImage(url: url)
        }
        
        articleScrollView.articleTitleLabel.text = article.title
        articleScrollView.articleDescriptionLabel.text = article.description
        articleScrollView.articleSourceLabel.text = "- \(article.source)"
        articleScrollView.articleDateLabel.text = "\(article.publishedDate.description(with: .current))"
        articleScrollView.textView.attributedText = NSAttributedString(string: article.url.absoluteString, attributes: [
            .link: article.url.absoluteString,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ])
    }
}

extension ArticleViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        openFullNews()
        return false
    }
}
