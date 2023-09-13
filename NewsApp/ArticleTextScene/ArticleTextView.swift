//
//  ArticleTextView.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 13.02.23.
//

import UIKit
import WebKit

class ArticleTextView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(webView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = bounds
    }
    
    let webView: WKWebView = {
        WKWebView()
    }()
}
