//
//  Localization.swift
//  Tracker
//
//  Created by Захар Панченко on 17.07.2025.
//
import Foundation

enum Localization {
    static let trackers = NSLocalizedString("trackers", comment: "Trackers title")
    static let statistics = NSLocalizedString("statistics", comment: "Statistics title")
    static let filters = NSLocalizedString("filters", comment: "Filters button")
    static let search = NSLocalizedString("search", comment: "Search placeholder")
    static let whatToTrack = NSLocalizedString("whatToTrack", comment: "Empty state text")
    static let nothingFound = NSLocalizedString("nothingFound", comment: "Nothing found text")
    static let day = NSLocalizedString("day", comment: "Day singular")
    static let days = NSLocalizedString("days", comment: "Days plural")
    static let confirmDelete = NSLocalizedString("confirmDelete", comment: "Delete confirmation")
    static let delete = NSLocalizedString("delete", comment: "Delete button")
    static let cancel = NSLocalizedString("cancel", comment: "Cancel button")
    
    static func daysCount(_ count: Int) -> String {
        let formatString: String
        
        if count % 10 == 1 && count % 100 != 11 {
            formatString = NSLocalizedString("%d day", comment: "Singular day format")
        } else if (2...4).contains(count % 10) && !(12...14).contains(count % 100) {
            formatString = NSLocalizedString("%d days", comment: "Plural days format (2-4)")
        } else {
            formatString = NSLocalizedString("%d days", comment: "Plural days format")
        }
        
        return String.localizedStringWithFormat(formatString, count)
    }
}
