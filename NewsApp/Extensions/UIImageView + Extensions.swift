//
//  UIImageView + Extensions.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

extension UIImageView {
    func setImage(url: URL) {
        Task {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .returnCacheDataElseLoad
            
            let (data, _) = try await URLSession(configuration: config).data(from: url)
            self.image = UIImage(data: data)
        }
    }
}
