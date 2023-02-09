//
//  UIImageView.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

extension UIImageView {
    func setImage(url: URL?) {
        guard let url = url else { return }
        
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image = UIImage(data: data)
        }
    }
}
