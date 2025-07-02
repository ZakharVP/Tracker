//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 03.05.2025.
//

import UIKit

class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    private let nameLabel               = UILabel()
    private let nameTextFieldContainer  = UIView()
    private let nameTextField           = UITextField()
    private let doneButton              = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNameLabel()
        setupCustomTextField()
        setupDoneButton()
        
        setupConstraints()
        setupHideKeyboardOnTap()
        
    }
    
    private func setupNameLabel() {
        nameLabel.text = "Название категории"
        nameLabel.font = .systemFont(ofSize: 17, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupCustomTextField() {
        // Контейнер
        nameTextFieldContainer.isUserInteractionEnabled = true
        nameTextFieldContainer.backgroundColor = .systemGray6
        nameTextFieldContainer.layer.cornerRadius = 16
        nameTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Текстовое поле
        nameTextField.isUserInteractionEnabled = true
        nameTextField.placeholder = "Введите название категории"
        nameTextField.font = .systemFont(ofSize: 16)
        nameTextField.backgroundColor = .clear
        nameTextField.borderStyle = .none
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Отступ слева
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        
        // Отступ справа (чтобы текст не заезжал под крестик)
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        nameTextField.rightView = rightPaddingView
        nameTextField.rightViewMode = .unlessEditing
        
        nameTextFieldContainer.addSubview(nameTextField)
        view.addSubview(nameTextFieldContainer)
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .gray
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func doneButtonTapped() {
        
        guard let categoryName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !categoryName.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите название категории")
            return
        }
        
        if TrackerDataStore.shared.getAllCategories().contains(where: { $0.title.lowercased() == categoryName.lowercased()}) {
            showAlert(title: "Ошибка", message: "Категория с таким именем уже существует")
            return
        }
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        TrackerDataStore.shared.addCategory(newCategory)
        
        dismiss(animated: true)
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if nameTextField.text != nil && nameTextField.text!.isEmpty == false {
            doneButton.backgroundColor = .black
        } else {
            doneButton.backgroundColor = .gray
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            nameTextFieldContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            nameTextFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextFieldContainer.heightAnchor.constraint(equalToConstant: 75),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameTextFieldContainer.leadingAnchor, constant: 0),
            nameTextField.trailingAnchor.constraint(equalTo: nameTextFieldContainer.trailingAnchor, constant: 0),
            nameTextField.topAnchor.constraint(equalTo: nameTextFieldContainer.topAnchor, constant: 0),
            nameTextField.bottomAnchor.constraint(equalTo: nameTextFieldContainer.bottomAnchor, constant: 0),
            
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
            
        ])
    }
}
