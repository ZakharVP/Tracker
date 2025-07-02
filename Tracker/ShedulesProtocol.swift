//
//  ShedulesProtocol.swift
//  Tracker
//
//  Created by Захар Панченко on 04.05.2025.
//

protocol SheduleSelectionDelegate: AnyObject {
    func didSelectShedule(_ shedule: [WeekDay])
}
