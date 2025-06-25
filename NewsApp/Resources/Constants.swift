//
//  Constants.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 21.02.24.
//

import Foundation

enum K {
    
    private static let decoder = PropertyListDecoder()
    
    static func loadAPIKeys() async throws {
        guard APIKeys.newsAPIKey == nil else { return }
        
        let request = NSBundleResourceRequest(tags: ["API Keys"])
        try await request.beginAccessingResources()
        
        let url = Bundle.main.url(forResource: "API Keys", withExtension: "plist")!
        let data = try Data(contentsOf: url)
        
        APIKeys.storage = try decoder.decode([String: String].self, from: data)
        
        request.endAccessingResources()
    }
    
    enum APIKeys {
        static fileprivate(set) var storage = [String: String]()
        
        static var newsAPIKey: String? {
            storage["News API"]
        }
    }
}
