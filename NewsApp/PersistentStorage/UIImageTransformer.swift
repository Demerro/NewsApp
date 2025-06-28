//
//  UIImageTransformer.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 27.06.25.
//

import UIKit

final class UIImageTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? UIImage else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: data)
    }
}
