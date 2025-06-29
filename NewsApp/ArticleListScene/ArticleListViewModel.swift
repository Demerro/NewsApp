//
//  ArticleListViewModel.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.09.23.
//

import Foundation
import Combine
import UIKit

final class ArticleListViewModel: ObservableObject {
    
    private var topics: Set<String> = ["war", "crime", "finance", "medicine", "bitcoin", "tesla"]
    
    private var cancellables = Set<AnyCancellable>()
    
    let articlesSubject = PassthroughSubject<Void, Never>()
    private(set) var articles = [Article]()
    private(set) var isLoadingArticles = false
    
    let didSelectArticleSubject = PassthroughSubject<Article.ID, Never>()
    
    let errorMessageSubject = CurrentValueSubject<String, Never>("")
    
    var onShowArticle: ((Article) -> Void)? = nil
    
    private let newsClient: NewsClient
    private let articlesStorageClient: ArticlesStorageClient
    private let imageDownloader: ImageDownloader
    
    init(articlesStorageClient: ArticlesStorageClient, newsClient: NewsClient, imageDownloader: ImageDownloader) {
        self.articlesStorageClient = articlesStorageClient
        self.newsClient = newsClient
        self.imageDownloader = imageDownloader
    }
}

extension ArticleListViewModel {
    
    func restoreCacheArticles() {
        articlesStorageClient.articlesPublisher
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessageSubject.send(error.localizedDescription)
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                articles = $0
            }
            .store(in: &cancellables)
    }
}

extension ArticleListViewModel {
    
    private func incrementWatchCounter(for url: URL) {
        for index in articles.indices where articles[index].url == url {
            articles[index].watchCounter += 1
        }
        articlesStorageClient.watchCounterIncrementalSubject.send(url)
    }
}

extension ArticleListViewModel {
 
    private var articlesPublisher: AnyPublisher<[Article], Never> {
        guard let topic = topics.randomElement() else { return Just([]).eraseToAnyPublisher() }
        topics.remove(topic)
        return newsClient.getArticles(about: topic)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingArticles = false
            }, receiveCompletion: { [weak self] _ in
                self?.isLoadingArticles = false
            })
            .receive(on: DispatchQueue.main)
            .catch { [weak self] error -> AnyPublisher<[Article], Never> in
                self?.errorMessageSubject.send(error.localizedDescription)
                return Just([]).eraseToAnyPublisher()
            }
            .flatMap { [weak self] articles -> AnyPublisher<[Article], Never> in
                guard let self else {
                    return Just(articles).eraseToAnyPublisher()
                }
                
                let articlePublishers = articles.map { article in
                    self.articlesStorageClient.watchCounterPublisher(for: article.url)
                        .map { watchCounterEntity in
                            Article(
                                source: article.source,
                                title: article.title,
                                description: article.description,
                                url: article.url,
                                urlToImage: article.urlToImage,
                                publishedDate: article.publishedDate,
                                image: article.image,
                                watchCounter: Int(watchCounterEntity?.count ?? 0)
                            )
                        }
                        .catch { _ in Just(article) }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(articlePublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func refreshNews() {
        guard !isLoadingArticles else { return }
        isLoadingArticles = true
        articlesPublisher
            .filter { !$0.isEmpty }
            .sink { [weak self] in
                guard let self else { return }
                articles = $0
                articlesSubject.send(())
            }
            .store(in: &cancellables)
    }
    
    func appendNews() {
        guard !isLoadingArticles else { return }
        isLoadingArticles = true
        articlesPublisher
            .filter { !$0.isEmpty }
            .sink { [weak self] in
                guard let self else { return }
                articles.append(contentsOf: $0)
                articlesSubject.send(())
            }
            .store(in: &cancellables)
    }
}

extension ArticleListViewModel {
    
    func loadImage(for index: Int) async -> UIImage? {
        guard let urlToImage = articles[index].urlToImage else { return nil }
        let image = try? await imageDownloader.loadImage(for: urlToImage)
        articles[index].image = image
        return image
    }
    
    func cancelImageLoading(for index: Int) {
        guard let urlToImage = articles[index].urlToImage else { return }
        imageDownloader.cancelImageLoadingIfNeeded(for: urlToImage)
    }
}

extension ArticleListViewModel {
    
    func selectArticle(at index: Int) {
        let article = articles[index]
        onShowArticle?(article)
        incrementWatchCounter(for: article.url)
        didSelectArticleSubject.send(article.id)
    }
}

extension ArticleListViewModel: ArticlesStorageClient.DataProvider {
}
