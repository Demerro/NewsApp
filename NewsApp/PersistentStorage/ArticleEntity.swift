//
//  ArticleEntity.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 28.06.25.
//

import CoreData
import UIKit

public final class ArticleEntity: NSManagedObject {
}

extension ArticleEntity {

    public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }

    @NSManaged public var articleDescription: String?
    @NSManaged public var image: UIImage?
    @NSManaged public var publishedDate: Date?
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var url: URL?
}
