//
//  Untitled.swift
//  Tracker
//
//  Created by Захар Панченко on 04.05.2025.
//

// 85a0f939-5479-481a-adfa-9330c3571335 API key Yandex metrica

import UIKit

final class TrackerDataStore {
    // Singleton instance
    static let shared = TrackerDataStore()
    static let categoriesDidChange = Notification.Name("categoriesDidChange")
    static let trackerDidChange = Notification.Name("trackerDidChange")
    
    // Private init to prevent creating multiple instances
    private init() {}
    
    // MARK: - Properties
    
    private var categories: [TrackerCategory] = []
    private var records: [TrackerRecord] = []
    
    // MARK: - Categories Methods
    
    func addCategory(_ category: TrackerCategory) {
        categories.append(category)
        NotificationCenter.default.post(name: Self.categoriesDidChange, object: nil)
    }
    
    func getAllCategories() -> [TrackerCategory] {
        return categories
    }
    
    func getCategory(for title: String) -> TrackerCategory? {
        return categories.first { $0.title == title }
    }
    
    // MARK: - Trackers Methods
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        print("Добавление трекера: \(tracker.title) в категорию: \(categoryTitle)")
        
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            categories[index].trackers.append(tracker)
            print("Трекер добавлен в существующую категорию")
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
            print("Создана новая категория с трекером")
        }
        
        print("Текущее состояние хранилища:")
        categories.forEach { print("Категория: \($0.title), трекеров: \($0.trackers.count)") }
        
        NotificationCenter.default.post(name: Self.trackerDidChange, object: nil)
    }
    
    func getTrackers(for categoryTitle: String) -> [Tracker] {
        return categories.first { $0.title == categoryTitle }?.trackers ?? []
    }
    
    func getAllTrackers() -> [Tracker] {
        return categories.flatMap { $0.trackers }
    }
    
    func getTracker(by id: UUID) -> Tracker? {
        return getAllTrackers().first { $0.id == id }
    }
    
    // MARK: - Records Methods
    
    func addRecord(_ record: TrackerRecord) {
        records.append(record)
    }
    
    func removeRecord(_ record: TrackerRecord) {
        records.removeAll { $0.trackerId == record.trackerId && $0.date == record.date }
    }
    
    func getAllRecords() -> [TrackerRecord] {
        return records
    }
    
    func getRecords(for trackerId: UUID) -> [TrackerRecord] {
        return records.filter { $0.trackerId == trackerId }
    }
    
    func getCompletedTrackersCount(for trackerId: UUID) -> Int {
        return records.filter { $0.trackerId == trackerId }.count
    }
    
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return records.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
