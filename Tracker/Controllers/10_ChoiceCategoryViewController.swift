//
//  ChoiceCategoryViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 03.05.2025.
//

import UIKit

final class ChoiceCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CategorySelectionDelegate?
    private let viewModel: ChoiceCategoryViewModel
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "star_center")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellCategory")
        tableView.rowHeight = 75
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .gray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \n объединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: ChoiceCategoryViewModel = ChoiceCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не инициализирован")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        setupBindings()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(nameLabel)
        view.addSubview(imageView)
        view.addSubview(doneButton)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        
        let initialHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        initialHeightConstraint.priority = .defaultLow
        initialHeightConstraint.isActive = true
        
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
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        ])
    }
    
    private func setupBindings() {
        viewModel.categoriesDidChange = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.isEmptyStateDidChange = { [weak self] isEmpty in
            print("isEmptyStateDidChange вызван. isEmpty: \(isEmpty)")
            self?.imageView.isHidden = !isEmpty
            self?.descriptionLabel.isHidden = !isEmpty
            self?.tableView.isHidden = isEmpty
        }
        
        viewModel.tableViewHeightDidChange = { [weak self] height in
            guard let self = self else { return }
            self.tableView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = height
                }
            }
            self.tableView.isScrollEnabled = height >= self.viewModel.maxHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func doneButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        present(newCategoryVC, animated: true)
    }
}

extension ChoiceCategoryViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath)
        
        cell.textLabel?.text = viewModel.categoryTitle(at: indexPath.row)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        
        if indexPath.row != viewModel.categories.count - 1 {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.selectCategory(at: indexPath.row)
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true)
    }
}
