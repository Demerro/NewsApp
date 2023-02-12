//
//  ArticleView.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit

class ArticleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addSubview(articleImageView)
        addSubview(articleTitle)
        addSubview(articleDescription)
        addSubview(articleSource)
        addSubview(articleDate)
        addSubview(fullTextButton)
        
        addConstraints([
            articleImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            articleImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            articleImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            articleImageView.heightAnchor.constraint(equalToConstant: 200),
            
            articleTitle.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 20),
            articleTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            articleTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            articleDescription.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 20),
            articleDescription.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            articleDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            articleSource.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            articleSource.topAnchor.constraint(equalTo: articleDescription.bottomAnchor, constant: 10),
            
            articleDate.topAnchor.constraint(equalTo: articleSource.bottomAnchor, constant: 10),
            articleDate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            articleDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            fullTextButton.topAnchor.constraint(equalTo: articleDate.bottomAnchor),
            fullTextButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -20),
            fullTextButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        articleImageView.layer.cornerRadius = 10
        articleImageView.layer.masksToBounds = true
    }
    
    func configure(with article: Article) {
        articleImageView.setImage(url: URL(string: article.urlToImage!))
        articleTitle.text = article.title
        articleDescription.text = article.description
        articleSource.text = "- \(article.source.name)"
        
        let date = ISO8601DateFormatter().date(from: article.publishedAt)!
        articleDate.text = "\(date.description(with: .current))"
        
        fullTextButton.setTitle(article.url, for: .normal)
    }
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let articleTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let articleDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let articleSource: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let articleDate: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let fullTextButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
