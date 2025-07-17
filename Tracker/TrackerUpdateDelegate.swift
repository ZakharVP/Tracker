//
//  TrackerUpdateDelegate.swift
//  Tracker
//
//  Created by Захар Панченко on 16.07.2025.
//

protocol TrackerUpdateDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker, category: String)
}
