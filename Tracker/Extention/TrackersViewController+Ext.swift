//
//  ViewController+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 26.04.2025.
//

import UIKit

extension TrackersViewController {
    
    func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        let newCategories: [TrackerCategory]
        
        if let index = categories.firstIndex(where: { $0.title == categoryTitle}) {
            let oldCategory = categories[index]
            let newTrackers = oldCategory.trackers + [tracker]
            let newCategory = TrackerCategory(title: categoryTitle, trackers: newTrackers)
            
            newCategories = categories.map { $0.title == categoryTitle ? newCategory : $0}
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories = categories + [newCategory]
        }
        
        categories = newCategories
        collectionView.reloadData()
        updateUI()
    }
    
    func removeTracker(withId id: UUID) {
        categories = categories.compactMap { category in
            let newTrackers = category.trackers.filter { $0.id != id}
            return newTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: newTrackers)
        }
    }
    
    func compeleteTracker(withId id: UUID, date: Date) {
        let selectedDate = datePicker.date
        guard !isTrackerCompleted(id, on: selectedDate) else { return }
        
        completedTrackers.insert(id)  // Заменяем append на insert для Set
        print("Добавлена запись: \(id). Всего записей: \(completedTrackers.count)")
    }
    
    func uncompletedTrackers(witchId id: UUID, date: Date) {
        let selectedDate = datePicker.date
        let countBefore = completedTrackers.count
        completedTrackers.remove(id)  // Удаляем по UUID
        
        print("Удалены записи. Было: \(countBefore), стало: \(completedTrackers.count)")
    }
    
    func isTrackerCompleted(_ id: UUID, on date: Date) -> Bool {
        completedTrackers.contains(id)  // Проверяем только по UUID
    }
    
    func completedDaysCount(for trackerId: UUID, on date: Date? = nil) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        var predicates = [NSPredicate]()
        
        // Фильтр по ID трекера
        predicates.append(NSPredicate(format: "tracker.id == %@", trackerId as CVarArg))
        
        // Фильтр по дате (если передана)
        if let date = date {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            predicates.append(NSPredicate(
                format: "dateCompleted >= %@ AND dateCompleted < %@",
                startOfDay as CVarArg,
                endOfDay as CVarArg
            ))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let records = try CoreDataManager.shared.context.fetch(request)
            return records.count
        } catch {
            print("Ошибка при получении записей: \(error)")
            return 0
        }
    }
    
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reportEvent(event: "click", item: "track")
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        print("Выбран трекер: \(tracker.title)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TrackerCell",
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let selectedDate = datePicker.date
        let isCompleted = isTrackerCompleted(tracker.id, on: selectedDate)
        let canBeCompleted = selectedDate <= Date()
        let completedDays = completedDaysCount(for: tracker.id)
        
        cell.configure(
            with: tracker,
            completedDays: completedDaysCount(for: tracker.id),
            isCompleted: completedTrackers.contains(tracker.id),
            canBeCompleted: canBeCompleted
        ) { [weak self] trackerId, isCompleted in
            self?.toggleTrackerCompletion(trackerId: trackerId, isCompleted: isCompleted)
        }
        
        return cell
    }
    
    func toggleTrackerCompletion(trackerId: UUID, isCompleted: Bool) {
        let selectedDate = datePicker.date // Используем дату из datePicker
        
        if completedTrackers.contains(trackerId) {
            try? recordStore.deleteRecord(trackerId: trackerId, date: selectedDate)
        } else {
            try? recordStore.addRecord(trackerId: trackerId, date: selectedDate)
        }
        
        // Обновляем UI
        loadCompletedTrackers(for: selectedDate)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(with: categories[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func trackersDidUpdate() {
        print("Получено уведомление об обновлении трекеров")
        DispatchQueue.main.async {
            self.loadData()
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.section)-\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil
        ) { _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteTracker(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
