//
//  StorageManager.swift
//  MirnaiaNV_HW2.13
//
//  Created by Наталья Мирная on 25/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import CoreData

class StorageManager {
    
    static let instance = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MirnaiaNV_HW2_13")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
