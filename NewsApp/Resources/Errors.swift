//
//  Errors.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case clientOrTransportSpecific(URLError)
    case clientOrTransport(Error)
    case server(HTTPURLResponse)
    case noData
    case unknown
}
