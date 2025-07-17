//
//  ViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 10.04.2025.
//

import UIKit
import AppMetricaCore

final class TrackersViewController: UIViewController, TrackerCreationDelegate {
    let recordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        
        let russianLocale = Locale(identifier: "ru_RU")
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = russianLocale
        
        picker.locale = russianLocale
        picker.calendar = calendar
        picker.preferredDatePickerStyle = .compact
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(dateDidChange(_:)), for: .valueChanged)
        
        return picker
    }()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    
    private let filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.filters, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonPlus      = UIButton(type: .system)
    private let titleLabel      = UILabel()
    private let searchBar       = UISearchBar()
    private let mainImage       = UIImageView()
    private let centerLabel     = UILabel()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.backgroundColor = UIColor(named: "main-background")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var currentFilter: TrackerFilter = .all
    var isFilterActive: Bool = false {
        didSet {
            filtersButton.setTitleColor(isFilterActive ? .red : .white, for: .normal)
        }
    }
    
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .mainBackground)
        
        setupButtonPlus()
        setupDatePicker()
        
        setupTitleLabel()
        setupSearchBar()
        setupMainImage()
        setupCenterLabel()
        setupCollectionView()
        
        loadData()
        
        setupLanguageObserver()
        
        NSLayoutConstraint.activate([
            buttonPlus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            buttonPlus.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            buttonPlus.widthAnchor.constraint(equalToConstant: 42),
            buttonPlus.heightAnchor.constraint(equalToConstant: 42),
            
            titleLabel.topAnchor.constraint(equalTo: buttonPlus.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            mainImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            centerLabel.topAnchor.constraint(equalTo: mainImage.bottomAnchor, constant: 8),
            centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerLabel.widthAnchor.constraint(equalToConstant: 343)
            
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reportEvent(event: "open")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        reportEvent(event: "close")
    }
    
    private func setupLanguageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    private func setupButtonPlus() {
        if let image = UIImage(named: "plus") {
            buttonPlus.setImage(image, for: .normal)
        }
        buttonPlus.tintColor = .label //.black
        buttonPlus.addTarget(self, action: #selector(buttonPlusTapped), for: .touchUpInside)
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonPlus)
    }
    
    private func setupDatePicker() {
        view.addSubview(datePicker)
    }
    
    private func setupTitleLabel() {
        titleLabel.textAlignment = .left
        titleLabel.text = Localization.trackers
        titleLabel.textColor = .label //.black
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = Localization.search
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.rightView = nil
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            let imageView = textField.leftView as? UIImageView
            imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
            imageView?.tintColor = .systemGray
        }
        view.addSubview(searchBar)
    }
    
    private func setupMainImage() {
        mainImage.contentMode = .scaleAspectFit
        mainImage.image = UIImage(named: "star_center")
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainImage)
    }
    
    private func setupCenterLabel() {
        centerLabel.text = Localization.whatToTrack
        centerLabel.textAlignment = .center
        centerLabel.textColor = .label //.black
        centerLabel.numberOfLines = 0
        centerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLabel)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let category = categories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        do {
            try trackerStore.deleteTracker(with: tracker.id)
            categories[indexPath.section].trackers.remove(at: indexPath.row)
            
            // Если категория пустая, удаляем ее
            if categories[indexPath.section].trackers.isEmpty {
                categories.remove(at: indexPath.section)
            }
            
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
    
    private func daysText(for count: Int) -> String {
        let key: String
        let remainder = count % 10
        
        if count % 100 >= 11 && count % 100 <= 19 {
            key = "days"
        } else {
            switch remainder {
            case 1: key = "day"
            case 2...4: key = "days2"
            default: key = "days"
            }
        }
        
        return String.localizedStringWithFormat(NSLocalizedString(key, comment: ""), count)
    }
    
    func reportEvent(event: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": "Main"
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        AppMetrica.reportEvent(name: "TrackerEvent", parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        // Дублируем в логи для тестов
        print("Event reported: \(params)")
    }
    
    func didCreateTracker(_ tracker: Tracker, category: String) {
        loadData()
    }
    
    func confirmDeleteTracker(at indexPath: IndexPath) {
        reportEvent(event: "click", item: "delete")
        let alert = UIAlertController(
            title: "",
            message: Localization.confirmDelete,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: Localization.delete, style: .destructive) { [weak self] _ in
            self?.deleteTracker(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func editTracker(at indexPath: IndexPath) {
        reportEvent(event: "click", item: "edit")
        
        let category = categories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        let editVC = HabitTrackerViewController()
        editVC.trackerToEdit = tracker
        editVC.daysCount = completedDaysCount(for: tracker.id)
        editVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }
    
    func loadCompletedTrackers(for date: Date) {
        let records = recordStore.fetchRecords()
        completedTrackers = Set(records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .map { $0.trackerId })
    }
    
    func loadData() {
        categories = trackerStore.fetchAllCategories()
        updateUI()
    }
    
    func updateUI() {
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.kind == .habit || tracker.kind == .irregularEvent
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        self.categories = filteredCategories
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        let hasNoTrackers = categories.isEmpty
        mainImage.isHidden = !hasNoTrackers
        centerLabel.isHidden = !hasNoTrackers
        
        if hasNoTrackers {
            if isFilterActive {
                mainImage.image = UIImage(resource: .imageNoFiltres)
                centerLabel.text = Localization.nothingFound
            } else {
                mainImage.image = UIImage(resource: .starCenter)
                centerLabel.text = "Что будем отслеживать?"
            }
        }
        
        searchBar.isHidden = hasNoTrackers
        collectionView.isHidden = hasNoTrackers
        filtersButton.isHidden = hasNoTrackers
    }
    
    @objc private func languageChanged() {
        titleLabel.text = Localization.trackers
        searchBar.placeholder = Localization.search
        filtersButton.setTitle(Localization.filters, for: .normal)
        
        if categories.isEmpty {
            centerLabel.text = isFilterActive ? Localization.nothingFound : Localization.whatToTrack
        }
        
        collectionView.reloadData()
    }
    
    
    @objc func buttonPlusTapped() {
        reportEvent(event: "click", item: "add_track")
        print("button plus tapped")
        let choiceTypeTrackerVC = ChoiceTypeTracker()
        
        let navController = UINavigationController(rootViewController: choiceTypeTrackerVC)
        
        choiceTypeTrackerVC.modalPresentationStyle = .pageSheet
        choiceTypeTrackerVC.overrideUserInterfaceStyle = .dark
        
        navController.navigationBar.isHidden = true
        self.present(navController, animated: true)
        
    }
    
    @objc private func dateDidChange(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбрана дата:", formattedDate)
        
        loadCompletedTrackers(for: selectedDate)
        
        switch currentFilter {
        case .all:
            loadData()
        case .today:
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                datePicker.date = Date()
            }
            loadData()
        case .completed:
            applyCompletedFilter()
        case .uncompleted:
            applyUncompletedFilter()
        }
        
        updatePlaceholderVisibility()
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    @objc private func filtersButtonTapped() {
        reportEvent(event: "click", item: "filter")
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        present(filtersVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
}
