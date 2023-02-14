//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit

class ArticleViewController: UIViewController {
    
    private let articleView = ArticleView()
    private var currentArticle: Article? = nil
    
    init(article: Article) {
        currentArticle = article
        articleView.configure(with: article)
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

        articleView.fullTextButton.addTarget(self, action: #selector(openFullNews), for: .touchUpInside)
    }
    
    @objc private func openFullNews() {
        guard let articleURL = currentArticle?.url,
              let url = URL(string: articleURL)
        else {
            return
        }
        let viewController = ArticleTextViewController(articleURL: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
