//
//  ArticleListViewModel.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.09.23.
//

import Foundation
import Combine

final class ArticleListViewModel: ObservableObject {
    
    private let topic = ["war", "crime", "finance", "medicine", "bitcoin", "tesla"]
    
    private var cancellables = Set<AnyCancellable>()
    
    let articlesSubject = PassthroughSubject<Void, Never>()
    var articles = [Article]()
    private(set) var isLoadingArticles = false
    
    let errorMessageSubject = CurrentValueSubject<String, Never>("")
    
    private let newsClient: NewsClient
    private let articlesStorageClient: ArticlesStorageClient
    
    init(articlesStorageClient: ArticlesStorageClient, newsClient: NewsClient) {
        self.articlesStorageClient = articlesStorageClient
        self.newsClient = newsClient
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
                articlesSubject.send(Void())
            }
            .store(in: &cancellables)
    }
}

extension ArticleListViewModel {
 
    private var articlePublisher: AnyPublisher<[Article], Error> {
        newsClient.getArticles(about: topic.randomElement()!)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingArticles = false
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func refreshNews() {
        guard !isLoadingArticles else { return }
        isLoadingArticles = true
        articlePublisher
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessageSubject.send(error.localizedDescription)
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                articles = $0
                articlesSubject.send(Void())
            }
            .store(in: &cancellables)
    }
    
    func appendNews() {
        guard !isLoadingArticles else { return }
        isLoadingArticles = true
        articlePublisher
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessageSubject.send(error.localizedDescription)
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                articles.append(contentsOf: $0)
                articlesSubject.send(Void())
            }
            .store(in: &cancellables)
    }
}

extension ArticleListViewModel: ArticlesStorageClient.DataProvider {
}
