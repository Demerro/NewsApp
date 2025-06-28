//
//  ArticlesStorageClient.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 25.06.25.
//

import CoreData
import OSLog
import Combine

final class ArticlesStorageClient {
    
    let saveArticlesSubject = PassthroughSubject<Void, Never>()
    
    weak var dataProvider: (any DataProvider)? = nil
    
    private var saveArticleCancellable: AnyCancellable? = nil
    
    private let persistentContainer: NSPersistentContainer
    
    init() {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName(String(describing: UIImageTransformer.self)))
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { [weak saveArticlesSubject] _, error in
            if error != nil {
                Logger.articleStorageClient.error("Failed to load persistent stores: \(error)")
                saveArticlesSubject?.send(completion: .finished)
            }
        }
        binding()
    }
}

extension ArticlesStorageClient {
    
    private func binding() {
        saveArticleCancellable = saveArticlesSubject
            .compactMap { [unowned self] in
                dataProvider?.articles.suffix(20)
            }
            .flatMap { $0.publisher }
            .map { article -> [String: Any] in
                [
                    Key.articleDescription.rawValue: article.description as Any,
                    Key.publishedDate.rawValue: article.publishedDate,
                    Key.source.rawValue: article.source,
                    Key.title.rawValue: article.title,
                    Key.url.rawValue: article.url,
                    Key.image.rawValue: article.image as Any,
                ]
            }
            .collect(20)
            .tryMap { [self] insertDictionaries in
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: ArticleEntity.fetchRequest())
                let batchRequest = NSBatchInsertRequest(entity: ArticleEntity.entity(), objects: insertDictionaries)
                try persistentContainer.viewContext.execute(deleteRequest)
                try persistentContainer.viewContext.execute(batchRequest)
                try persistentContainer.viewContext.save()
            }
            .sink(receiveCompletion: { [unowned persistentContainer] in
                if case let .failure(error) = $0 {
                    Logger.articleStorageClient.error("Failed to save articles: \(error)")
                    persistentContainer.viewContext.rollback()
                }
            }, receiveValue: { _ in
                Logger.articleStorageClient.info("Successfully saved articles.")
            })
    }
}

extension ArticlesStorageClient {
    
    var articlesPublisher: AnyPublisher<[Article], Error> {
        Future<[ArticleEntity], Error> { [unowned persistentContainer] promise in
            let fetchRequest = ArticleEntity.fetchRequest()
            do {
                promise(.success(try persistentContainer.viewContext.fetch(fetchRequest)))
            } catch {
                promise(.failure(error))
            }
        }
        .flatMap { $0.publisher }
        .map { Article(source: $0.source!, title: $0.title!, description: $0.description, url: $0.url!, urlToImage: nil, publishedDate: $0.publishedDate!, image: $0.image) }
        .collect()
        .eraseToAnyPublisher()
    }
}

extension ArticlesStorageClient {
    
    private enum Key: String {
        case articleDescription
        case publishedDate
        case source
        case title
        case url
        case image
    }
    
    protocol DataProvider: AnyObject {
        var articles: [Article] { get }
    }
}

extension Logger {
    
    fileprivate static let articleStorageClient = Logger(subsystem: Bundle.main.bundleIdentifier!, category: NSStringFromClass(ArticlesStorageClient.self))
}
