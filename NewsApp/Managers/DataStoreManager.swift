//
//  DataStoreManager.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 14.02.23.
//

import CoreData

class DataStoreManager {
    
    static let shared = DataStoreManager()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? persistentContainer.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
