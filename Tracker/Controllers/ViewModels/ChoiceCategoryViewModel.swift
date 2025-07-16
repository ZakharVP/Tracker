//
//  ChoiceCategoryViewModel.swift
//  Tracker
//
//  Created by Захар Панченко on 12.07.2025.
//

import Foundation

final class ChoiceCategoryViewModel {
    
    var categoriesDidChange: (() -> Void)?
    var isEmptyStateDidChange: ((Bool) -> Void)?
    var tableViewHeightDidChange: ((CGFloat) -> Void)?
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?()
            updateEmptyState()
            updateTableViewHeight()
        }
    }
    
    let rowHeight: CGFloat = 75
    let maxHeight: CGFloat = 525
    
    init(categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
            self.categoryStore = categoryStore
            setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CategoriesDidUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("Получено уведомление о обновлении категорий") 
            self?.loadCategories()
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = categories.isEmpty
        print("updateEmptyState вызван. categories.isEmpty: \(isEmpty)")
        isEmptyStateDidChange?(categories.isEmpty)
    }
    
    private func updateTableViewHeight() {
        let calculatedHeight = CGFloat(categories.count) * rowHeight
        let height = min(calculatedHeight, maxHeight)
        print("Высота таблицы: \(height)")
        DispatchQueue.main.async { 
            self.tableViewHeightDidChange?(height)
        }
    }
    
    func loadCategories() {
        let loadedCategories = categoryStore.fetchAllCategories()
        print("Загружено категорий в ViewModel: \(loadedCategories.count)")
        self.categories = loadedCategories
    }
    
    func categoryTitle(at index: Int) -> String {
        guard index >= 0 && index < categories.count else { return "" }
        return categories[index].title
    }
    
    func selectCategory(at index: Int) -> String {
        guard index >= 0 && index < categories.count else { return "" }
        return categories[index].title
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension Notification.Name {
    static let categoriesDidUpdate = Notification.Name("CategoriesDidUpdate")
}
