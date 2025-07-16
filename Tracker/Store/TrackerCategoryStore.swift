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
        print("Попытка создать категорию: \(title)")
        
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
        request.sortDescriptors = [NSSortDescriptor(key: "nameCategoryTracker", ascending: true)]
        
        do {
            let categoriesCoreData = try context.fetch(request)
            print("Найдено категорий в Core Data: \(categoriesCoreData.count)")
            
            return categoriesCoreData.compactMap { coreDataCategory in
                guard let title = coreDataCategory.nameCategoryTracker else { return nil }
                
                // Получаем трекеры для категории
                let trackers = (coreDataCategory.tracker?.allObjects as? [TrackerCoreData])?
                    .compactMap { $0.toTracker() } ?? []
                
                print("Категория: \(title), трекеров: \(trackers.count)")
                
                return TrackerCategory(
                    title: title,
                    trackers: trackers
                )
            }
        } catch {
            print("Ошибка загрузки категорий: \(error)")
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
