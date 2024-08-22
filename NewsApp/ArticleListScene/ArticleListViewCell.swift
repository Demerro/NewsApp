//
//  ArticleListViewCell.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

final class ArticleListViewCell: UICollectionViewCell {
    
    private let articleImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView(frame: .zero))
    
    private let articleTitle: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        $0.textColor = .white
        return $0
    }(UILabel(frame: .zero))
    
    private let articleImageViewGradientLayer: CAGradientLayer = {
        $0.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        $0.locations = [0, 1]
        return $0
    }(CAGradientLayer())
    
    override func layoutSubviews() {
        super.layoutSubviews()
        RunLoop.current.add(Timer(timeInterval: 0.0, repeats: false, block: { [self] _ in
            articleImageViewGradientLayer.frame = articleImageView.frame
        }), forMode: .common)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleListViewCell {
    
    func configure(with article: Article) {
        if let url = article.urlToImage {
            articleImageView.setImage(url: url)
        }
        articleTitle.text = article.title
    }
}

extension ArticleListViewCell {
    
    private func setupCommon() {
        clipsToBounds = true
        layer.cornerRadius = 10.0
        
        articleImageView.layer.addSublayer(articleImageViewGradientLayer)
        contentView.addSubview(articleImageView)
        contentView.addSubview(articleTitle)
    }
    
    private func setupConstraints() {
        let articleTitleTopAnchor = articleTitle.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor, constant: 10.0)
        articleTitleTopAnchor.priority = .defaultLow
        NSLayoutConstraint.activate([
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            articleTitleTopAnchor,
            articleTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
            contentView.trailingAnchor.constraint(equalTo: articleTitle.trailingAnchor, constant: 10.0),
            contentView.bottomAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 10.0),
        ])
    }
}
