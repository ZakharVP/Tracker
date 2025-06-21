//
//  ViewController+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 26.04.2025.
//

import UIKit

extension ViewController {
    
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
        
        let record = TrackerRecord(trackerId: id, date: selectedDate)
        completedTrackers.append(record)
        print("Добавлена запись: \(record). Всего записей: \(completedTrackers.count)")
    }
    
    func uncompletedTrackers(witchId id: UUID, date: Date) {
        let selectedDate = datePicker.date
        let countBefore = completedTrackers.count
        completedTrackers.removeAll { record in
            record.trackerId == id &&
            Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        print("Удалены записи. Было: \(countBefore), стало: \(completedTrackers.count)")
    }
    
    func isTrackerCompleted(_ id: UUID, on date: Date) -> Bool {
        completedTrackers.contains{ record in
            record.trackerId == id &&
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        return completedTrackers.filter {
            $0.trackerId == trackerId
        }.count
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
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
            completedDays: completedDays,
            isCompleted: isCompleted,
            canBeCompleted: canBeCompleted
        ) { [weak self] trackerId, isCompleted in
            guard let self = self else { return }
            
            let currentSelectedDate = self.datePicker.date
                
            if isCompleted {
                self.compeleteTracker(withId: trackerId, date: selectedDate)
            } else {
                self.uncompletedTrackers(witchId: trackerId, date: selectedDate)
            }


            DispatchQueue.main.async {
                if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
                    cell.updateDaysCount(self.completedDaysCount(for: trackerId))
                    cell.updateCompletionStatus(
                        isCompleted: self.isTrackerCompleted(trackerId, on: currentSelectedDate),
                        canBeCompleted: currentSelectedDate <= Calendar.current.startOfDay(for: Date())
                    )
                }
            }
        }
            
        return cell
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
