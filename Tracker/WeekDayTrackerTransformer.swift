//
//  WeekDayTrackerTransformer.swift
//  Tracker
//
//  Created by Захар Панченко on 17.07.2025.
//

import Foundation

@objc(WeekDayTrackerTransformer)
class WeekDayTrackerTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [NSArray.self, NSNumber.self] // Если это массив чисел (например, Int)
    }
    
    static func register() {
        let transformer = WeekDayTrackerTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("WeekDayTrackerTransformer"))
    }
}
