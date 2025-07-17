//
//  UIColor.swift
//  Tracker
//
//  Created by Захар Панченко on 17.07.2025.
//

import UIKit

extension UIColor {
    static var adaptiveBorderColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00) :
                    UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
            }
        } else {
            return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
        }
    }
}
