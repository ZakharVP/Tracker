//
//  IrregularEventTrackerViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 29.04.2025.
//

import UIKit

class IrregularEventTrackerViewController: UIViewController {
    
    private let nameLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNameUI()
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)

        ])
    }
    
    private func setupNameUI() {
        nameLabel.text = "Новое нерегулярное событие"
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
}
