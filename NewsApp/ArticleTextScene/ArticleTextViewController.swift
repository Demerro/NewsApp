//
//  ArticleTextViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 13.02.23.
//

import UIKit
import WebKit

final class ArticleTextViewController: UIViewController {

    let webView = WKWebView()
    
    override func loadView() {
        view = webView
    }
    
    init(articleURL: URL) {
        webView.load(URLRequest(url: articleURL))
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
