//
//  SecondViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 10.04.2025.
//

import UIKit

final class SecondViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.statistics
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .deadlineSmile)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateStats()
        setupLanguageObserver()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .mainBackground)
        
        view.addSubview(titleLabel)
        
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        
        // Add stats stack view
        view.addSubview(statsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupLanguageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    private func updateStats() {
        let completedTrackersCount = trackerRecordStore.fetchRecords().count
        let allTrackersCount = trackerStore.fetchTrackers().count
        
        if completedTrackersCount > 0 || allTrackersCount > 0 {
            showStats(completed: completedTrackersCount, total: allTrackersCount)
        } else {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        emptyStateImageView.isHidden = false
        emptyStateLabel.isHidden = false
        statsStackView.isHidden = true
    }
    
    private func showStats(completed: Int, total: Int) {
        emptyStateImageView.isHidden = true
        emptyStateLabel.isHidden = true
        statsStackView.isHidden = false
        
        // Clear existing stats
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add completed trackers stat
        let completedStatView = createStatView(value: completed, title: "Трекеров завершено")
        statsStackView.addArrangedSubview(completedStatView)
        
        // Add total trackers stat
        let totalStatView = createStatView(value: total, title: "Всего трекеров")
        statsStackView.addArrangedSubview(totalStatView)
    }
    
    private func createStatView(value: Int, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(resource: .mainBackground)
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Создаем градиентный слой для рамки
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        // Создаем форму для рамки
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 90), cornerRadius: 16).cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.cornerRadius = 16
        
        // Применяем маску градиента к форме
        gradientLayer.mask = shapeLayer
        
        // Создаем контейнер для градиента
        let gradientView = UIView()
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(gradientView)
        
        // Устанавливаем констрейнты для градиентной рамки
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: container.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Остальной код с лейблами
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем лейблы поверх градиента
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        // Обновляем слои после размещения
        DispatchQueue.main.async {
            gradientLayer.frame = gradientView.bounds
            shapeLayer.path = UIBezierPath(roundedRect: gradientView.bounds, cornerRadius: 16).cgPath
        }
        
        return container
    }
    
    @objc private func languageChanged() {
        titleLabel.text = Localization.statistics
        updateStats()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
}
