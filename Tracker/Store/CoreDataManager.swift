//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Не могу загрузить persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
}
