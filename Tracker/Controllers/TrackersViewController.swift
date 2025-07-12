//
//  ViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 10.04.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // Хранилища
    let recordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        
        // Создаем русскую локаль и календарь
        let russianLocale = Locale(identifier: "ru_RU")
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = russianLocale
        
        // Применяем настройки
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
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupButtonPlus()
        setupDatePicker()
        
        setupTitleLabel()
        setupSearchBar()
        setupMainImage()
        setupCenterLabel()
        setupCollectionView()
        
        loadData()
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupButtonPlus() {
        if let image = UIImage(named: "plus") {
            buttonPlus.setImage(image, for: .normal)
        }
        buttonPlus.tintColor = .black
        buttonPlus.addTarget(self, action: #selector(buttonPlusTapped), for: .touchUpInside)
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonPlus)
    }
    
    private func setupDatePicker() {
        view.addSubview(datePicker)
    }
    
    private func setupTitleLabel() {
        titleLabel.textAlignment = .left
        titleLabel.text = "Трекеры"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
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
        centerLabel.text = "Что будем отслеживать?"
        centerLabel.textAlignment = .center
        centerLabel.textColor = .black
        centerLabel.numberOfLines = 0
        centerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLabel)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        
        searchBar.isHidden = hasNoTrackers
        collectionView.isHidden = hasNoTrackers
    }
    
    
    @objc func buttonPlusTapped() {
        print("button plus tapped")
        let choiceTypeTrackerVC = ChoiceTypeTracker()
        
        let navController = UINavigationController(rootViewController: choiceTypeTrackerVC)
        
        choiceTypeTrackerVC.modalPresentationStyle = .pageSheet
        choiceTypeTrackerVC.overrideUserInterfaceStyle = .dark
        
        navController.navigationBar.isHidden = true
        self.present(navController, animated: true)
        
    }
    
    @objc private func dateDidChange(_ sender: UIDatePicker) {
        let formattedDate = dateFormatter.string(from: sender.date)
        print("Выбрана дата:", formattedDate)
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
}

