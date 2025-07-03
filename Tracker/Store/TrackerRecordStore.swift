//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//

import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(trackerId: UUID, date: Date) throws
    func fetchRecords() -> [TrackerRecord]
    func deleteRecord(trackerId: UUID, date: Date) throws
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext = CoreDataManager.shared.context
    
    func addRecord(trackerId: UUID, date: Date) throws {
        // Нормализуем дату (убираем время)
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        let trackerRequest = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let tracker = try context.fetch(trackerRequest).first else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        // Проверяем, не существует ли уже записи для этой даты
        let existingRequest = TrackerRecordCoreData.fetchRequest()
        existingRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND dateCompleted == %@",
            trackerId as CVarArg,
            normalizedDate as CVarArg
        )
        
        if try context.count(for: existingRequest) > 0 {
            // Запись уже существует, можно выбросить ошибку или просто вернуться
            return
        }
        
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.dateCompleted = normalizedDate
        record.tracker = tracker
        
        try context.save()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordsCoreData = try context.fetch(request)
            return recordsCoreData.map { coreDataRecord in
                TrackerRecord(
                    trackerId: coreDataRecord.tracker?.id ?? UUID(),
                    date: coreDataRecord.dateCompleted ?? Date()
                )
            }
        } catch {
            print("Не могу получить записи: \(error)")
            return []
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND dateCompleted == %@",
            trackerId as CVarArg,
            normalizedDate as CVarArg
        )
        
        guard let record = try context.fetch(request).first else {
            throw TrackerRecordStoreError.recordNotFound
        }
        
        context.delete(record)
        try context.save()
    }
}

enum TrackerRecordStoreError: Error {
    case trackerNotFound
    case recordNotFound
}
