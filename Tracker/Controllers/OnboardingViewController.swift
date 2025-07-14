//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 14.07.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    init(imageName: String, title: String) {
        super.init(nibName: nil, bundle: nil)
        setupImage(with: imageName)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupImage(with name: String) {
        guard let image = UIImage(named: name) else {
            print("Изображение \(name) не загружено!")
            imageView.backgroundColor = .systemRed
            return
        }
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setupViews() {
        view.backgroundColor = .white // Явно задаем белый фон
        
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
           
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Заголовок
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304) 

        ])
    }
}
