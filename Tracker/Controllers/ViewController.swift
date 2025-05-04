//
//  ViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 10.04.2025.
//

import UIKit

class ViewController: UIViewController {

    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return button
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private let buttonPlus  = UIButton(type: .system)
    private let titleLabel  = UILabel()
    private let searchBar   = UISearchBar()
    private let mainImage   = UIImageView()
    
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
    
    var trackers:           [Tracker] = []
    var categories:         [TrackerCategory] = []
    var completedTrackers:  [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        setupButtonPlus()
        setupDateButton()
        setupTitleLabel()
        setupSearchBar()
        setupMainImage()
        setupCollectionView()
        
        updateUI()
       
        NSLayoutConstraint.activate([
            buttonPlus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            buttonPlus.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16),
            buttonPlus.widthAnchor.constraint(equalToConstant: 42),
            buttonPlus.heightAnchor.constraint(equalToConstant: 42),
            
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16),
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.heightAnchor.constraint(equalToConstant: 34),
            
            titleLabel.topAnchor.constraint(equalTo: buttonPlus.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            mainImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        ])
        
        updateDateButton(with: Date())
        updateUI()
        
        NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleTrackersUpdate),
             name: TrackerDataStore.trackerDidChange,
             object: nil
         )
        
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
    
    private func setupDateButton() {
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dateButton)
    }
    
    private func updateDateButton(with date: Date) {
        let formattedDate = dateFormatter.string(from: date)
        dateButton.setTitle(formattedDate, for: .normal)
    }
    
    private func setupTitleLabel() {
        titleLabel.textAlignment = .center
        titleLabel.text = "Трекеры"
        titleLabel.textColor = .black
        
        if let sfProBold = UIFont(name: "SFPro-Bold", size: 34) {
            titleLabel.font = sfProBold
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.leftView = nil
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
    
    func updateUI() {
        // Всегда берем актуальные данные из хранилища
          self.categories = TrackerDataStore.shared.getAllCategories()
          let isEmpty = categories.isEmpty
          
          collectionView.isHidden = isEmpty
          mainImage.isHidden = !isEmpty
          
          // Всегда обновляем коллекцию
          collectionView.reloadData()
          
          print("Обновление UI. Количество категорий: \(categories.count)")
          categories.forEach { print("Категория: \($0.title), трекеров: \($0.trackers.count)") }
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
    
    @objc private func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let alert = UIAlertController(
            title: "Выберите дату",
            message: "\n\n\n\n\n\n\n\n\n\n",
            preferredStyle: .actionSheet
        )
        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 45)
        ])
        
        let okAction = UIAlertAction(title: "Готово", style: .default) { [weak self] _ in
            let formattedDate = self?.dateFormatter.string(from: datePicker.date) ?? "Не выбрана дата"
            self?.dateButton.setTitle(formattedDate, for: .normal)
        }
        
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
        
    }
    
    @objc private func handleTrackersUpdate() {
        print("Получено уведомление об изменении трекеров")
        DispatchQueue.main.async {
            self.updateUI()
        }
    }

}

