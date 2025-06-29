//
//  ArticleListViewCell.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

final class ArticleListViewCell<ItemIdentifier: Hashable>: UICollectionViewCell {
    
    var itemIdentifier: ItemIdentifier?
    
    private let articleImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
        return $0
    }(UIImageView(frame: .zero))
    
    private let articleTitleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .white
        return $0
    }(UILabel(frame: .zero))
    
    private let watchCounterLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .white
        return $0
    }(UILabel(frame: .zero))
    
    private let gradientView: LayerView<CAGradientLayer> = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        $0.setLayer.locations = [0, 1]
        return $0
    }(LayerView<CAGradientLayer>(frame: .zero))
    
    private var resizingTask: Task<Void, Never>? = nil
    
    override var isHighlighted: Bool {
        didSet {
            let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8)
            animator.addAnimations { [self] in
                transform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
            animator.startAnimation()
        }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemIdentifier = nil
    }
    
    deinit {
        resizingTask?.cancel()
    }
}

extension ArticleListViewCell {
    
    func apply(configuration: Configuration) {
        articleTitleLabel.text = configuration.text
        if let watchCounter = configuration.watchCounter {
            watchCounterLabel.text = "Watched: \(watchCounter)"
        }
        resizingTask?.cancel()
        if let cgImage = configuration.image?.cgImage {
            resizingTask = Task {
                let image = UIImage(cgImage: cgImage, scale: traitCollection.displayScale, orientation: .up)
                let thumbnail = await image.byPreparingThumbnail(ofSize: articleImageView.bounds.size)
                let resultImage = await thumbnail?.byPreparingForDisplay()
                UIView.transition(with: articleImageView, duration: CATransaction.animationDuration(), options: .curveEaseInOut) {
                    self.articleImageView.image = resultImage
                }
            }
        } else {
            articleImageView.image = nil
        }
    }
}

extension ArticleListViewCell {
    
    private func setupCommon() {
        clipsToBounds = true
        layer.cornerRadius = 10.0
        
        contentView.addSubview(articleImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(watchCounterLabel)
    }
    
    private func setupConstraints() {
        watchCounterLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            articleTitleLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
            articleTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: articleTitleLabel.trailingAnchor, multiplier: 1.0),
            
            watchCounterLabel.topAnchor.constraint(equalToSystemSpacingBelow: articleTitleLabel.bottomAnchor, multiplier: 1.0),
            watchCounterLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: watchCounterLabel.trailingAnchor, multiplier: 1.0),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: watchCounterLabel.bottomAnchor, multiplier: 1.0),
        ])
    }
}

extension ArticleListViewCell {
    
    struct Configuration {
        var text: String?
        var watchCounter: Int?
        var image: UIImage?
        
        init() {
        }
    }
}
