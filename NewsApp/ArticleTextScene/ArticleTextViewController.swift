//
//  ArticleTextViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 13.02.23.
//

import UIKit

class ArticleTextViewController: UIViewController {

    private let articleTextView = ArticleTextView()
    
    init(articleURL: URL) {
        articleTextView.webView.load(URLRequest(url: articleURL))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = articleTextView
    }
}
