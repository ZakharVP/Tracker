//
//  ChoiceTypeTracker.swift
//  Tracker
//
//  Created by Захар Панченко on 29.04.2025.
//

import UIKit

class ChoiceTypeTracker: UIViewController {
    
    private let nameLabel = UILabel()
    private let habitButton = UIButton()
    private let irregularEventButton = UIButton()
    private let darkIndicatorView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
     
        setupNameUI()
        setupHabitButton()
        setupIrregularEventButton()
        setupDarkIndicator()
        setupConstraints()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.overrideUserInterfaceStyle = .dark
    }
    
    private func setupDarkIndicator() {
         
         darkIndicatorView.backgroundColor = .black
         darkIndicatorView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(darkIndicatorView)
     }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 281),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            
            darkIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            darkIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            darkIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            darkIndicatorView.heightAnchor.constraint(equalToConstant: 1)

        ])
        
    }
    
    private func setupNameUI() {
        nameLabel.text = "Создание трекера"
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupHabitButton() {
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.white, for: .normal)
        habitButton.layer.cornerRadius = 16
        habitButton.backgroundColor = .black
        habitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
    }
    
    private func setupIrregularEventButton() {
        irregularEventButton.setTitle("Нерегулярные событие", for: .normal)
        irregularEventButton.setTitleColor(.white, for: .normal)
        irregularEventButton.backgroundColor = .black
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.addTarget(self, action: #selector(didTapIrregularEventButton), for: .touchUpInside)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
    }
    
    @objc func didTapHabitButton() {
        let habitTrackerVC = HabitTrackerViewController()
        if let mainVC = presentingViewController as? ViewController {
            habitTrackerVC.delegate = mainVC
        }
        self.present(habitTrackerVC, animated: true)
    }
    
    @objc func didTapIrregularEventButton() {
        let irregularEventTrackerVC = IrregularEventTrackerViewController()
        self.present(irregularEventTrackerVC, animated: true)
    }
    
}

extension ChoiceTypeTracker: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        // Добавляем трекер в хранилище
        TrackerDataStore.shared.addTracker(tracker, to: category)
        
        // Закрываем все модальные окна до главного экрана
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("TrackersDidUpdate"), object: nil)
        }
    }
}
