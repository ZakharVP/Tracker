//
//  TrackersViewControllerSnapShotTests.swift
//  TrackerTests
//
//  Created by Захар Панченко on 17.07.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    var sut: TrackersViewController!
    
    override func setUp() {
        super.setUp()
        sut = TrackersViewController()
        sut.loadViewIfNeeded()
        
        // Настройка состояния для теста
        let testDate = Date(timeIntervalSince1970: 0)
        sut.datePicker.date = testDate
        
        // Загрузка тестовых данных
        let testTrackers = [
            Tracker(
                id: UUID(),
                title: "Тестовый трекер",
                color: .red,
                emoji: "😀",
                shedule: [.monday, .wednesday, .friday],
                kind: .habit
            )
        ]
        let testCategory = TrackerCategory(title: "Тестовая категория", trackers: testTrackers)
        sut.categories = [testCategory]
        
        // Обновление UI
        sut.updateUI()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testTrackersViewController() {
        // Устанавливаем фиксированный размер экрана для стабильности тестов
        sut.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        assertSnapshot(
            of: sut,
            as: .image(on: .iPhoneX),
            named: "default",
            record: false //true для первого запуска
        )
    }
}
