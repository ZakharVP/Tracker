//
//  TrackerCoreData+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 03.07.2025.
//

import UIKit

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = id,
              let name = nameTracker,
              let emoji = emojiTracker,
              let color = colorTracker as? UIColor else {
            return nil
        }
        
        let schedule: [WeekDay]
        if let weekDays = weekDaysTracker as? [Int] {
            schedule = weekDays.compactMap { WeekDay(rawValue: $0) }
        } else {
            schedule = []
        }
        
        return Tracker(
            id: id,
            title: name,
            color: color,
            emoji: emoji,
            shedule: schedule,
            kind: .habit
        )
    }
}
