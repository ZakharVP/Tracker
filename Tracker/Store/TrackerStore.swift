//
//  TrackerStore.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackersDidUpdate()
}

protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws
    func fetchTrackers() -> [Tracker]
    func fetchTrackers(for categoryTitle: String) -> [Tracker]
    func fetchAllCategories() -> [TrackerCategory]
    func deleteTracker(with id: UUID) throws
    
    var delegate: TrackerStoreDelegate? { get set }
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStoreProtocol
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context,
         categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        print("Настройка NSFetchedResultsController")
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreateTracker", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            print("NSFetchedResultsController успешно настроен")
        } catch {
            print(" Ошибка при инициализации FetchedResultsController: \(error)")
        }
        
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        return categoryStore.fetchAllCategories()
    }
    
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let category = try categoryStore.fetchOrCreateCategory(with: categoryTitle)
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let trackerCoreData = TrackerCoreData(context: self.context)
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
            
            do {
                print("Данные трекера подготовлены, сохраняем контекст")
                try self.context.save()
                print("Контекст успешно сохранен")
            } catch {
                print("Ошибка при сохранении контекста: \(error)")
            }
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects.compactMap { $0.toTracker() }
    }
    
    func fetchTrackers(for categoryTitle: String) -> [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects
            .filter { $0.category?.nameCategoryTracker == categoryTitle }
            .compactMap { $0.toTracker() }
    }
    
    
    func deleteTracker(with id: UUID) throws {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request = TrackerCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                if let tracker = try self.context.fetch(request).first {
                    self.context.delete(tracker)
                    try self.context.save()
                }
            } catch {
                print("Failed to delete tracker: \(error)")
            }
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("NSFetchedResultsController обнаружил изменения!")
        delegate?.trackersDidUpdate()
    }
}

enum TrackerStoreError: Error {
    case trackerNotFound
}
