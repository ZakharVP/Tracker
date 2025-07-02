//
//  TrackerCreationDelegate.swift
//  Tracker
//
//  Created by Захар Панченко on 30.04.2025.
//

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}
