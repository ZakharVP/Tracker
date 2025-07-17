//
//  NSValueTransformer.swift
//  Tracker
//
//  Created by Захар Панченко on 17.07.2025.
//

import UIKit

@objc(ColorTrackerTransformer)
class ColorTrackerTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
    
    static func register() {
        let transformer = ColorTrackerTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("ColorTrackerTransformer"))
    }
}
