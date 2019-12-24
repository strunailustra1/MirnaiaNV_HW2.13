//
//  TaskRepository.swift
//  MirnaiaNV_HW2.13
//
//  Created by Наталья Мирная on 25/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit
import CoreData

class TaskRepository {
    
    static let instance = TaskRepository()
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchAll() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    func create(taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Task",
            in: viewContext
        )
        else { return nil }
        
        let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as! Task
        task.name = taskName
        
        return saveContext() ? task : nil
    }
    
    func update(task: Task, newName: String) -> Bool {
        let oldName = task.name
        task.name = newName
        
        let isSave = saveContext()
        if  isSave == false {
            task.name = oldName
        }
        
        return isSave
    }
    
    func delete(_ task: Task) -> Bool {
        viewContext.delete(task)
        return saveContext()
    }
    
    private func saveContext() -> Bool {
        do {
            try self.viewContext.save()
        } catch let error {
            print(error)
            return false
        }
        
        return true
    }
}
