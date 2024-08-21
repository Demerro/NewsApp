//
//  ArticleScrollView.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit

final class ArticleScrollView: UIScrollView {
    
    private let stackView: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20.0
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView(frame: .zero))
    
    let articleImageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerCurve = .continuous
        $0.layer.cornerRadius = 10.0
        return $0
    }(UIImageView(frame: .zero))
    
    let articleTitleLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .title2, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        $0.numberOfLines = 0
        return $0
    }(UILabel(frame: .zero))
    
    let articleDescriptionLabel: UILabel = {
        let descriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitItalic)!
        $0.font = UIFont(descriptor: descriptor, size: descriptor.pointSize)
        $0.numberOfLines = 0
        return $0
    }(UILabel(frame: .zero))
    
    let articleSourceLabel: UILabel = {
        let descriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitItalic)!
        $0.font = UIFont(descriptor: descriptor, size: descriptor.pointSize)
        $0.numberOfLines = 0
        return $0
    }(UILabel(frame: .zero))
    
    let articleDateLabel: UILabel = {
        let descriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitItalic)!
        $0.font = UIFont(descriptor: descriptor, size: descriptor.pointSize)
        $0.numberOfLines = 0
        return $0
    }(UILabel(frame: .zero))
    
    let textView: UnselectableTappableTextView = {
        $0.backgroundColor = .systemGroupedBackground
        $0.isScrollEnabled = false
        $0.textContainer.lineFragmentPadding = .zero
        $0.isUserInteractionEnabled = true
        return $0
    }(UnselectableTappableTextView(frame: .zero))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleScrollView {
    
    private func setupCommon() {
        backgroundColor = .systemGroupedBackground
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        addSubview(stackView)
        stackView.addArrangedSubview(articleImageView)
        stackView.addArrangedSubview(articleTitleLabel)
        stackView.addArrangedSubview(articleDescriptionLabel)
        stackView.addArrangedSubview(articleSourceLabel)
        stackView.addArrangedSubview(articleDateLabel)
        stackView.addArrangedSubview(textView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            articleImageView.heightAnchor.constraint(equalToConstant: 200.0),
        ])
    }
}
