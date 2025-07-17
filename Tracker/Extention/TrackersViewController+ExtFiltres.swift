//
//  TrackersViewController+ExtFiltres.swift
//  Tracker
//
//  Created by Захар Панченко on 16.07.2025.
//
import UIKit

extension TrackersViewController: FiltersDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        isFilterActive = (filter != .all && filter != .today)
        
        switch filter {
        case .all:
            applyNoFilter()
        case .today:
            datePicker.date = Date()
            applyNoFilter()
        case .completed:
            applyCompletedFilter()
        case .uncompleted:
            applyUncompletedFilter()
        }
        
        updatePlaceholderVisibility()
    }
    
    private func applyNoFilter() {
        loadData()
    }
    
    func applyCompletedFilter() {
        let selectedDate = datePicker.date
        let completedTrackers = recordStore.fetchRecords()
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .map { $0.trackerId }
        
        categories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                completedTrackers.contains(tracker.id)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
    }
    
    func applyUncompletedFilter() {
        let selectedDate = datePicker.date
        let completedTrackers = recordStore.fetchRecords()
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .map { $0.trackerId }
        
        categories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                !completedTrackers.contains(tracker.id)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
    }
}
