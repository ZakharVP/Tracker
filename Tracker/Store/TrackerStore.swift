//
//  TrackerStore.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//
import CoreData

protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws
    func fetchTrackers() -> [Tracker]
    func fetchTrackers(for categoryTitle: String) -> [Tracker]
    func deleteTracker(with id: UUID) throws
}

final class TrackerStore: TrackerStoreProtocol {
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStoreProtocol
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context,
         categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.context = context
        self.categoryStore = categoryStore
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let category = try categoryStore.fetchOrCreateCategory(with: categoryTitle)
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.nameTracker = tracker.title
        trackerCoreData.emojiTracker = tracker.emoji
        trackerCoreData.colorTracker = tracker.color
        trackerCoreData.dateCreateTracker = Date()
        trackerCoreData.category = category
        
        if !tracker.shedule.isEmpty {
               trackerCoreData.weekDaysTracker = tracker.shedule.map { $0.rawValue } as NSObject
           } else {
               trackerCoreData.weekDaysTracker = nil
           }
           
        try context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        
        do {
            let trackersCoreData = try context.fetch(request)
            return trackersCoreData.compactMap { $0.toTracker() }
        } catch {
            print("Не могу получить привычки: \(error)")
            return []
        }
    }
    
    func fetchTrackers(for categoryTitle: String) -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.nameCategoryTracker == %@", categoryTitle)
        
        do {
            let trackersCoreData = try context.fetch(request)
            return trackersCoreData.compactMap { $0.toTracker() }
        } catch {
            print("Не могу получить привычки для категории: \(error)")
            return []
        }
    }
    
    func deleteTracker(with id: UUID) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let tracker = try context.fetch(request).first else {
            throw TrackerStoreError.trackerNotFound
        }
        
        context.delete(tracker)
        try context.save()
    }
}

enum TrackerStoreError: Error {
    case trackerNotFound
}
