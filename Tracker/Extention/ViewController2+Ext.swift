//
//  ViewController2+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 30.04.2025.
//
import UIKit

extension ViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
