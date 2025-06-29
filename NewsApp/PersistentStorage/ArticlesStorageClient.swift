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
    
    let watchCounterIncrementalSubject = PassthroughSubject<URL, Never>()
    
    weak var dataProvider: (any DataProvider)? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
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
        bindSaveArticlesSubject()
        bindWatchCounterIncrementalSubject()
    }
}

extension ArticlesStorageClient {
    
    private func bindSaveArticlesSubject() {
        saveArticlesSubject
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
            .tryMap { [unowned persistentContainer] insertDictionaries in
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
            .store(in: &cancellables)
    }
    
    var articlesPublisher: AnyPublisher<[Article], Error> {
        Future<[ArticleEntity], Error> { [unowned persistentContainer] promise in
            let fetchRequest = ArticleEntity.fetchRequest()
            do {
                promise(.success(try persistentContainer.viewContext.fetch(fetchRequest)))
            } catch {
                promise(.failure(error))
            }
        }
        .flatMap { [unowned self] articleEntities in
            let publishers = articleEntities.map { articleEntity in
                watchCounterPublisher(for: articleEntity.url)
                    .map { watchCounterEntity in
                        Article(
                            source: articleEntity.source,
                            title: articleEntity.title,
                            description: articleEntity.articleDescription,
                            url: articleEntity.url,
                            urlToImage: nil,
                            publishedDate: articleEntity.publishedDate,
                            image: articleEntity.image,
                            watchCounter: Int(watchCounterEntity?.count ?? 0)
                        )
                    }
            }
            return Publishers.MergeMany(publishers).collect()
        }
        .eraseToAnyPublisher()
    }
}

extension ArticlesStorageClient {
    
    private func bindWatchCounterIncrementalSubject() {
        watchCounterIncrementalSubject
            .tryMap { [unowned persistentContainer] url in
                let fetchRequest = WatchCounterEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
                fetchRequest.fetchLimit = 1
                fetchRequest.resultType = .managedObjectResultType
                if let result = try persistentContainer.viewContext.fetch(fetchRequest).first {
                    result.count += 1
                } else {
                    let watchCounter = WatchCounterEntity(context: persistentContainer.viewContext)
                    watchCounter.url = url
                    watchCounter.count = 1
                }
                try persistentContainer.viewContext.save()
            }
            .sink(receiveCompletion: { [unowned persistentContainer] in
                if case let .failure(error) = $0 {
                    Logger.articleStorageClient.error("Failed to update watch counter: \(error)")
                    persistentContainer.viewContext.rollback()
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }
    
    func watchCounterPublisher(for url: URL) -> AnyPublisher<WatchCounterEntity?, Error> {
        Future<WatchCounterEntity?, Error> { [unowned persistentContainer] promise in
            let fetchRequest = WatchCounterEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "url == %@", url as NSURL)
            fetchRequest.fetchLimit = 1
            do {
                promise(.success(try persistentContainer.viewContext.fetch(fetchRequest).first))
            } catch {
                promise(.failure(error))
            }
        }
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
