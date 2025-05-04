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
        guard !isTrackerCompleted(id, on: date) else { return }
        let record = TrackerRecord(trackerId: id, date: date)
        completedTrackers.append(record)
    }
    
    func uncompletedTrackers(witchId id: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: Date())
        }
    }
    
    func isTrackerCompleted(_ id: UUID, on date: Date) -> Bool {
        completedTrackers.contains{ record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
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
        let completedDays = completedDaysCount(for: tracker.id)
        let isCompletedToday = isTrackerCompleted(tracker.id, on: Date())
        
        cell.configure(
            with: tracker,
            completedDays: completedDays,
            isCompletedToday: isCompletedToday
        ) { [weak self] trackerId, isCompleted in
            if isCompleted {
                self?.compeleteTracker(withId: trackerId, date: Date())
            } else {
                self?.uncompletedTrackers(witchId: trackerId, date: Date())
            }
            collectionView.reloadItems(at: [indexPath])
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
