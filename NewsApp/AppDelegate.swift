//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        let dataStoreManager = DataStoreManager.shared
        let model = dataStoreManager.persistentContainer.managedObjectModel
        let context = dataStoreManager.persistentContainer.viewContext
        let fetchRequest = model.fetchRequestTemplate(forName: "AllArticles")!
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            if fetchedObjects.count < 20 {
                return
            }
            
            let deletingCount = fetchedObjects.count - 20
            
            for i in 0...deletingCount {
                context.delete(fetchedObjects[i] as! Article)
            }
            
            dataStoreManager.saveContext()
        } catch {
            print("Error when deleting unnecessary objects: \(error)")
        }
    }
}
