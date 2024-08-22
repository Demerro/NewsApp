//
//  ArticleListViewModel.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 19.09.23.
//

import Foundation
import Combine

final class ArticleListViewModel: ObservableObject {
    
    let topic = ["war", "crime", "finance", "medicine", "bitcoin", "tesla"]
    var cancellables = Set<AnyCancellable>()
    
    var articlesStorage = [Article]()
    @Published var articles = [Article]()
    @Published var errorMessage: String?
    
    private let newsClient = NewsClient()
    
    private var articlePublisher: AnyPublisher<[Article], Error> {
        return newsClient.getArticles(about: topic.randomElement()!)
            .compactMap { $0.isEmpty ? nil : $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func refreshNews() {
        articlePublisher
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.articles = $0
                self?.articlesStorage = $0
            }
            .store(in: &cancellables)
    }
    
    func appendNews() {
        articlePublisher
            .first()
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.articlesStorage.append(contentsOf: $0)
                self?.articles.append(contentsOf: $0)
            }
            .store(in: &cancellables)
    }
    
}
