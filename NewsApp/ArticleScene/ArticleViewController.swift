//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 11.02.23.
//

import UIKit
import Combine

final class ArticleViewController: UIViewController {
    
    private var imageTask: Task<Void, Never>? = nil
    
    let articleScrollView = ArticleScrollView()
    
    let viewModel: ArticleViewModel
    
    init(viewModel: ArticleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = articleScrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        articleScrollView.textView.delegate = self
        configureArticle()
    }
    
    deinit {
        imageTask?.cancel()
    }
}

extension ArticleViewController {
    
    private func configureArticle() {
        let article = viewModel.article
        imageTask = Task {
            let articleImage: UIImage? = if let image = article.image {
                image
            } else if let url = article.urlToImage {
                await viewModel.loadImage(for: url)
            } else {
                nil
            }
            if let cgImage = articleImage?.cgImage {
                let image = UIImage(cgImage: cgImage, scale: traitCollection.displayScale, orientation: .up)
                let thumbnail = await image.byPreparingThumbnail(ofSize: articleScrollView.articleImageView.bounds.size)
                let resultImage = await thumbnail?.byPreparingForDisplay()
                UIView.transition(with: articleScrollView.articleImageView, duration: CATransaction.animationDuration(), options: .curveEaseInOut) { [articleScrollView] in
                    articleScrollView.articleImageView.image = resultImage
                }
            } else {
                articleScrollView.articleImageView.image = nil
            }
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
        viewModel.openFullNews()
        return false
    }
}
