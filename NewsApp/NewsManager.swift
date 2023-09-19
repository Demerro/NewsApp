//
//  NewsManager.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation
import Combine

struct NewsClient {
    
    enum Error: LocalizedError {
        case clientOrTransport(URLError)
        case server(HTTPURLResponse)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .clientOrTransport(let urlError):
                return urlError.localizedDescription
            case .server(let response):
                return "The server has encountered a recovery problem that it does not know how to handle. Code \(response.statusCode)."
            case .unknown:
                return "Unknown error."
            }
        }
    }
    
    enum EndPoint {
        static let APIKey = "" // API key here
        static let baseURL = "https://newsapi.org/v2"
        static let maxArticles = 20
        
        case news(String)
        
        var url: URL {
            switch self {
            case .news(let keyword):
                let queryItems = [
                    URLQueryItem(name: "q", value: keyword),
                    URLQueryItem(name: "pageSize", value: String(NewsClient.EndPoint.maxArticles)),
                    URLQueryItem(name: "apiKey", value: NewsClient.EndPoint.APIKey)
                ]
                
                var components = URLComponents(string: NewsClient.EndPoint.baseURL + "/everything")!
                components.queryItems = queryItems
                
                return components.url!
            }
        }
    }
    
    private let decoder = JSONDecoder()
    
    func getNews(about keyword: String) -> AnyPublisher<News, Swift.Error> {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: config).dataTaskPublisher(for: EndPoint.news(keyword).url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NewsClient.Error.unknown
                }
                
                if 500...526 ~= httpResponse.statusCode {
                    throw NewsClient.Error.server(httpResponse)
                }
                
                return data
            }
            .mapError { error -> NewsClient.Error in
                switch error {
                case is URLError:
                    return NewsClient.Error.clientOrTransport(error as! URLError)
                default:
                    return error as? NewsClient.Error ?? .unknown
                }
            }
            .decode(type: News.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
}
