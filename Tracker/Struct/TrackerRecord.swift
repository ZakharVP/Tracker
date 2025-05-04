//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Захар Панченко on 26.04.2025.
//

import UIKit

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
    
    init (trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
}
