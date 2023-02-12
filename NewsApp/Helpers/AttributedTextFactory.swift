//
//  AttributedTextFactory.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 12.02.23.
//

import UIKit

class AttributedTextFactory {
    /// Makes the text look like a link
    /// - Parameters:
    ///     - text: Text that will appear as a link.
    /// - Returns: NSAttributedString which should look like default link.
    func makeLinkText(from text: String) -> NSAttributedString {
        let attributetString = NSMutableAttributedString(string: text)
        let linkAttributes = [
            NSAttributedString.Key.link: true,
            NSAttributedString.Key.underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]
        attributetString.setAttributes(linkAttributes, range: NSRange(location: 0, length: text.count))
        return attributetString
    }
}
