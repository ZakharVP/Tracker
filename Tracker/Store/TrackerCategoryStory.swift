//
//  TrackerCategoryStory.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//
import CoreData

protocol TrackerCategoryStoreProtocol {
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData
    func fetchAllCategories() -> [TrackerCategory]
    func deleteCategory(with title: String) throws
}

final class TrackerCategoryStore: TrackerCategoryStoreProtocol {
    private let context: NSManagedObjectContext = CoreDataManager.shared.context
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "nameCategoryTracker == %@", title)
        
        if let existingCategory = try context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.nameCategoryTracker = title
        try context.save()
        
        return newCategory
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categoriesCoreData = try context.fetch(request)
            return categoriesCoreData.map { coreDataCategory in
                let trackers = (coreDataCategory.tracker?.allObjects as? [TrackerCoreData])?
                    .compactMap { $0.toTracker() } ?? []
                
                return TrackerCategory(
                    title: coreDataCategory.nameCategoryTracker ?? "",
                    trackers: trackers
                )
            }
        } catch {
            print("Не могу получить категории: \(error)")
            return []
        }
    }
    
    func deleteCategory(with title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "nameCategoryTracker == %@", title)
        
        guard let category = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }
        
        context.delete(category)
        try context.save()
    }
}

enum TrackerCategoryStoreError: Error {
    case categoryNotFound
}
