//
//  NewsClient.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation
import Combine
import OSLog

struct NewsClient {
    
    private let decoder: JSONDecoder = {
        $0.dateDecodingStrategy = .iso8601
        return $0
    }(JSONDecoder())
    
    private let keyLoadingTask = Task {
        do {
            try await K.loadAPIKeys()
        } catch {
            Logger.newsClient.error("Failed to load API Keys: \(error)")
        }
    }
}

extension NewsClient {
    
    func getArticles(about keyword: String) -> AnyPublisher<[Article], Swift.Error> {
        Future { promise in
            Task {
                await keyLoadingTask.value
                promise(.success(Void()))
            }
        }
        .flatMap {
            URLSession.shared.dataTaskPublisher(for: EndPoint.news(keyword).url)
        }
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsClient.Error.unknown
            }
            
            if 500...526 ~= httpResponse.statusCode {
                throw NewsClient.Error.server(httpResponse)
            }
            
            return data
        }
        .decode(type: News.self, decoder: decoder)
        .mapError { error -> NewsClient.Error in
            switch error {
            case is URLError:
                Logger.newsClient.error("Network error: \(error)")
                return NewsClient.Error.clientOrTransport(error as! URLError)
            case is DecodingError:
                Logger.newsClient.error("Decoding error: \(error)")
                return NewsClient.Error.decoding(error as! DecodingError)
            default:
                Logger.newsClient.error("Unexpected error: \(error)")
                return error as? NewsClient.Error ?? .unknown
            }
        }
        .map(\.articles)
        .eraseToAnyPublisher()
    }
}

extension NewsClient {
    
    enum EndPoint {
        static let baseURL = "https://newsapi.org/v2"
        static let maxArticles = 20
        
        case news(String)
        
        var url: URL {
            switch self {
            case .news(let keyword):
                let queryItems = [
                    URLQueryItem(name: "q", value: keyword),
                    URLQueryItem(name: "pageSize", value: String(NewsClient.EndPoint.maxArticles)),
                    URLQueryItem(name: "apiKey", value: K.APIKeys.newsAPIKey)
                ]
                
                var components = URLComponents(string: NewsClient.EndPoint.baseURL + "/everything")!
                components.queryItems = queryItems
                
                return components.url!
            }
        }
    }
}

extension NewsClient {
    
    enum Error: LocalizedError {
        case clientOrTransport(URLError)
        case server(HTTPURLResponse)
        case decoding(DecodingError)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .clientOrTransport(let urlError):
                return urlError.localizedDescription
            case .server(let response):
                return "The server has encountered a recovery problem that it does not know how to handle. Code \(response.statusCode)."
            case .decoding(let decodingError):
                return "Decoding error: \(decodingError.localizedDescription)"
            case .unknown:
                return "Unknown error."
            }
        }
    }
}

extension Logger {
    
    fileprivate static let newsClient = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NewsClient")
}
