//
//  ImageDownloader.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 25.06.25.
//

import UIKit

final class ImageDownloader {
    
    private let cache = NSCache<NSURL, CacheEntryWrapper>()
}

extension ImageDownloader {
    
    @discardableResult
    func loadImage(for url: URL) async throws -> UIImage? {
        let nsURL = url as NSURL
        
        if let cacheEntryWrapper = cache.object(forKey: nsURL) {
            switch cacheEntryWrapper.entry {
            case let .ready(image):
                return image
            case let .inProgress(task):
                return try await task.value
            }
        }
        
        let task = Task {
            try UIImage(data: Data(contentsOf: url))
        }
        
        cache.setObject(CacheEntryWrapper(entry: .inProgress(task)), forKey: nsURL)
        
        do {
            let image = try await task.value
            cache.setObject(CacheEntryWrapper(entry: .ready(image)), forKey: nsURL)
            return image
        } catch {
            cache.removeObject(forKey: nsURL)
            throw error
        }
    }
    
    func cancelImageLoadingIfNeeded(for url: URL) {
        if case let .inProgress(task) = cache.object(forKey: url as NSURL)?.entry {
            task.cancel()
        }
    }
}

extension ImageDownloader {
    
    private enum CacheEntry {
        case inProgress(Task<UIImage?, Error>)
        case ready(UIImage?)
    }
    
    private class CacheEntryWrapper {
        
        let entry: CacheEntry
        
        init(entry: CacheEntry) {
            self.entry = entry
        }
    }
}
