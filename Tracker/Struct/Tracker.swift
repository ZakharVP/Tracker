//
//  Tracker.swift
//  Tracker
//
//  Created by Захар Панченко on 26.04.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let shedule: [WeekDay]?
    
    var isRegular: Bool {
        shedule != nil
    }
}

enum WeekDay: Int, CaseIterable, Codable {
    case monday     = 1
    case tuesday    = 2
    case wednesday  = 3
    case thursday   = 4
    case friday     = 5
    case saturday   = 6
    case sunday     = 7
    
    var shortName: String {
        switch self {
            case .monday:       return "Пн"
            case .tuesday:      return "Вт"
            case .wednesday:    return "Ср"
            case .thursday:     return "Чт"
            case .friday:       return "Пт"
            case .saturday:     return "Сб"
            case .sunday:       return "Вс"
        }
    }
}
