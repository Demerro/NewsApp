//
//  ArticleListViewCell.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

class ArticleListViewCell: UICollectionViewCell {
    
    static let identifier = NSStringFromClass(ArticleListViewCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [articleImageView, articleTitle, watchCounter].forEach { addSubview($0) }
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        articleImageView.frame = bounds
        articleImageViewGradientLayer.frame = bounds
        articleImageView.layer.addSublayer(articleImageViewGradientLayer)
        
        watchCounter.frame = CGRect(x: 10, y: bounds.height - 30, width: bounds.width - 20, height: 10)
        articleTitle.frame = CGRect(x: 10, y: 20, width: bounds.width - 20, height: bounds.height - watchCounter.bounds.height)
    }
    
    func configure(with article: Article) {
        if let urlString = article.urlToImage,
           let url = URL(string: urlString) {
            articleImageView.setImage(url: url)
        }
        articleTitle.text = article.title
    }
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let articleTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let watchCounter: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let articleImageViewGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0, 1]
        return layer
    }()
}
