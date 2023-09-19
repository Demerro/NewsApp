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
    
    @Published var articles = [Article]()
    @Published var errorMessage: String?
    
    private var articlePublisher: AnyPublisher<[Article], Error> {
        return NewsClient().getNews(about: topic.randomElement()!)
            .receive(on: DispatchQueue.main)
            .map(\.articles)
            .eraseToAnyPublisher()
    }
    
    func refreshNews() {
        articlePublisher
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessage = error.localizedDescription
                    print(error)
                }
            } receiveValue: { [weak self] in
                self?.articles = $0
            }
            .store(in: &cancellables)
    }
    
    func appendNews() {
        articlePublisher
            .first()
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    self?.errorMessage = error.localizedDescription
                    print(error)
                }
            } receiveValue: { [weak self] in
                self?.articles.append(contentsOf: $0)
            }
            .store(in: &cancellables)
    }
    
}
