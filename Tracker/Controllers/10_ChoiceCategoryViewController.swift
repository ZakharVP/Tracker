//
//  ChoiceCategoryViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 03.05.2025.
//

import UIKit

final class ChoiceCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CategorySelectionDelegate?
    let categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    var categories: [TrackerCategory] = []
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        
        // Убираем только у последней ячейки
        if indexPath.row != categories.count - 1 {
            let separator = UIView()
            separator.backgroundColor = .gray
            cell.contentView.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row].title
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true)
    }
    
    private let nameLabel = UILabel()
    private let imageView = UIImageView()
    private let doneButton = UIButton()
    private let tableView = UITableView()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNameLabel()
        setupImageView()
        setupDoneButton()
        setupTableView()
        setupDescriptionLabel()
        setupConstraints()
        
        loadCategories()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCategoriesChange),
            name: NSNotification.Name("CategoriesDidUpdate"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCategories()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func setupNameLabel() {
        nameLabel.text = "Категория"
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "star_center")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        
        view.addSubview(imageView)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Привычки и события можно \n объединить по смыслу"
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.isHidden = true
        
        view.addSubview(descriptionLabel)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellCategory")
        tableView.rowHeight = 75
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .gray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
    }
    
    private func calculateTableViewHeight() -> CGFloat {
        let rowHeight: CGFloat = 75
        let maxHeight: CGFloat = 525
        let calculatedHeight: CGFloat = CGFloat(categories.count) * rowHeight
        tableView.isScrollEnabled = calculatedHeight > maxHeight
        
        return min(calculatedHeight, maxHeight)
    }
    
    private func loadCategories() {
        categories = categoryStore.fetchAllCategories()
        setupUpdateUI()
    }
    
    private func setupUpdateUI() {
        let hasCategories = !categories.isEmpty
        imageView.isHidden = hasCategories
        descriptionLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
        
        tableView.reloadData()
        
        tableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = calculateTableViewHeight()
            }
        }
        view.layoutIfNeeded()
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Добавить категорию", for: .normal)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.topAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: calculateTableViewHeight()).priority(.defaultHigh),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        ])
        
    }
    
    @objc private func handleCategoriesChange() {
        loadCategories()
    }
    
    @objc private func doneButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        present(newCategoryVC, animated: true)
    }
}

extension NSLayoutConstraint {
    func priority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
