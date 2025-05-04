//
//  HabitTrackerViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 29.04.2025.
//

import UIKit

class HabitTrackerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmoji", for: indexPath)
                
            // Удаляем предыдущие subviews чтобы избежать наложения
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                
            let emojiLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height))
            emojiLabel.text = emojis[indexPath.row]
            emojiLabel.textAlignment = .center
            emojiLabel.font = UIFont.systemFont(ofSize: 32)
            cell.contentView.addSubview(emojiLabel)
                
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = 16
                
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColors", for: indexPath)
                
            // Удаляем предыдущие subviews
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                
            let colorView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height))
            colorView.backgroundColor = colors[indexPath.row]
            colorView.layer.cornerRadius = 8
            cell.contentView.addSubview(colorView)
                
            cell.contentView.backgroundColor = .clear
                
            return cell
        }
    }
    
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors: [UIColor] = [
            .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
            .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
            .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    
    private let nameTextFieldContainer   = UIView()
    private let nameTextField            = UITextField()
    private let nameCollectionEmojiView  = UILabel()
    private let nameCollectionColorsView = UILabel()
    
    private let buttonFalse      = UIButton(type: .system)
    private let buttonCreate     = UIButton(type: .system)
    
    let nameLabel = UILabel()
    let warningLabel = UILabel()
    
    var selectedCategory: String?
    var selectedDays: [WeekDay] = []
    var trackerTitle: String = ""
    weak var delegate: TrackerCreationDelegate?
    let tableView        = UITableView()
    
    let collectionEmoji: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    let collectionColors: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let tableData = ["Категория","Расписание"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNameUI()
        setupCustomTextField()
        setupWarningLabel()
        setupTableView()
        setupCollectionEmoji()
        setupCollectionColors()
        setupButtonFalse()
        setupButtonCreate()
        
        setupConstraints()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             self.nameTextField.becomeFirstResponder()
         }
    }
    
    private func setupWarningLabel() {
        warningLabel.text = "Ограничение: 38 символов"
        warningLabel.font = .systemFont(ofSize: 12)
        warningLabel.textColor = .red
        warningLabel.isHidden = true  // Сначала скрываем
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningLabel)
    }
    
    private func setupNameUI() {
        nameLabel.text = "Новая привычка"
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameCollectionEmojiView.text = "Emoji"
        nameCollectionEmojiView.font = UIFont.boldSystemFont(ofSize: 19)
        nameCollectionEmojiView.textColor = .black
        nameCollectionEmojiView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameCollectionEmojiView)
        
        nameCollectionColorsView.text = "Цвет"
        nameCollectionColorsView.font = UIFont.boldSystemFont(ofSize: 19)
        nameCollectionColorsView.textColor = .black
        nameCollectionColorsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameCollectionColorsView)
        
    }
    
    private func setupCustomTextField() {
        // Контейнер
        nameTextFieldContainer.isUserInteractionEnabled = true
        nameTextFieldContainer.backgroundColor = .systemGray6
        nameTextFieldContainer.layer.cornerRadius = 16
        nameTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Текстовое поле
        nameTextField.isUserInteractionEnabled = true
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.font = .systemFont(ofSize: 16)
        nameTextField.backgroundColor = .clear
        nameTextField.borderStyle = .none
        nameTextField.clearButtonMode = .whileEditing
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    private func setupCollectionEmoji() {
        collectionEmoji.delegate = self
        collectionEmoji.dataSource = self
        collectionEmoji.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellEmoji")
        collectionEmoji.backgroundColor = .clear
        collectionEmoji.layer.cornerRadius = 16
        collectionEmoji.isScrollEnabled = false
        collectionEmoji.allowsMultipleSelection = false
        view.addSubview(collectionEmoji)
    }

    private func setupCollectionColors() {
        collectionColors.delegate = self
        collectionColors.dataSource = self
        collectionColors.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellColors")
        collectionColors.backgroundColor = .clear
        collectionColors.layer.cornerRadius = 16
        collectionColors.isScrollEnabled = false
        collectionColors.allowsMultipleSelection = false
        view.addSubview(collectionColors)
    }
    
    private func setupButtonFalse() {
        buttonFalse.setTitle("Отменить", for: .normal)
        buttonFalse.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonFalse.setTitleColor(.red, for: .normal)
        buttonFalse.backgroundColor = .white
        buttonFalse.layer.cornerRadius = 16
        buttonFalse.layer.borderWidth = 1
        buttonFalse.layer.borderColor = UIColor.red.cgColor
        buttonFalse.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonFalse)
    }
    
    private func setupButtonCreate() {
        buttonCreate.setTitle("Создать", for: .normal)
        buttonCreate.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonCreate.setTitleColor(.white, for: .normal)
        buttonCreate.backgroundColor = .gray 
        buttonCreate.layer.cornerRadius = 16
        buttonCreate.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        buttonCreate.layer.shadowColor = UIColor.black.cgColor
        buttonCreate.layer.shadowOffset = CGSize(width: 0, height: 2)
        buttonCreate.layer.shadowRadius = 4
        buttonCreate.layer.shadowOpacity = 0.1
        buttonCreate.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonCreate)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            
            nameTextFieldContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            nameTextFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextFieldContainer.heightAnchor.constraint(equalToConstant: 75),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameTextFieldContainer.leadingAnchor, constant: 0),
            nameTextField.trailingAnchor.constraint(equalTo: nameTextFieldContainer.trailingAnchor, constant: 0),
            nameTextField.topAnchor.constraint(equalTo: nameTextFieldContainer.topAnchor, constant: 0),
            nameTextField.bottomAnchor.constraint(equalTo: nameTextFieldContainer.bottomAnchor, constant: 0),
            
            // warningLabel
            warningLabel.topAnchor.constraint(equalTo: nameTextFieldContainer.bottomAnchor, constant: 4),
            warningLabel.leadingAnchor.constraint(equalTo: nameTextFieldContainer.leadingAnchor, constant: 16),
                  
            // Обновляем констрейнт таблицы, чтобы она была под warningLabel
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            
            tableView.leadingAnchor.constraint(equalTo: nameTextFieldContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: nameTextFieldContainer.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            nameCollectionEmojiView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            nameCollectionEmojiView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                        
            collectionEmoji.topAnchor.constraint(equalTo: nameCollectionEmojiView.bottomAnchor, constant: 0),
            collectionEmoji.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionEmoji.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionEmoji.heightAnchor.constraint(equalToConstant: 150),
                        
            nameCollectionColorsView.topAnchor.constraint(equalTo: collectionEmoji.bottomAnchor, constant: 16),
            nameCollectionColorsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                        
            collectionColors.topAnchor.constraint(equalTo: nameCollectionColorsView.bottomAnchor, constant: 0),
            collectionColors.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionColors.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionColors.heightAnchor.constraint(equalToConstant: 150),
            
            // Кнопки
            buttonFalse.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonFalse.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonFalse.widthAnchor.constraint(equalToConstant: 160),
            buttonFalse.heightAnchor.constraint(equalToConstant: 60),
            
            buttonCreate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonCreate.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonCreate.widthAnchor.constraint(equalToConstant: 160),
            buttonCreate.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(processEditingDidEnd), object: nil)
        self.perform(#selector(processEditingDidEnd), with: nil, afterDelay: 0.5)
    }

    @objc func processEditingDidEnd() {
        guard let text = nameTextField.text else { return }
        trackerTitle = text
        print("Пользователь перестал вводить текст: \(nameTextField.text ?? "")")
        
        if text.count >= 2 {
               nameLabel.text = "Создание привычки"
           } else {
               nameLabel.text = "Новая привычка"
           }
        
        updateButtonCreateState()
    }
    
    @objc private func createButtonTapped() {
        print("Попытка создания трекера:")
        print("Название: \(trackerTitle)")
        print("Категория: \(selectedCategory ?? "не выбрана")")
        print("Дни: \(selectedDays.map { $0.shortName }.joined(separator: ", "))")
        
        guard !trackerTitle.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите название привычки")
            return
        }
        
        guard let category = selectedCategory else {
            showAlert(title: "Ошибка", message: "Выберите категорию")
            return
        }
        
        guard !selectedDays.isEmpty else {
            showAlert(title: "Ошибка", message: "Выберите расписание")
            return
        }
        
        let newTracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: selectedColor ?? .systemBlue,
            emoji: selectedEmoji ?? "🙂",
            shedule: selectedDays
        )
   
        // Сохраняем в хранилище
        TrackerDataStore.shared.addTracker(newTracker, to: category)
        
        // Уведомляем делегата
        delegate?.didCreateTracker(newTracker, category: category)
        
        // Закрываем модальные окна
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionEmoji {
            selectedEmoji = emojis[indexPath.row]
            // Можно добавить визуальное выделение выбранной ячейки
        } else {
            selectedColor = colors[indexPath.row]
            // Можно добавить визуальное выделение выбранной ячейки
        }
        updateButtonCreateState()
    }
    
    func updateButtonCreateState() {
        let isEnabled = !trackerTitle.isEmpty && selectedCategory != nil && !selectedDays.isEmpty
        buttonCreate.backgroundColor = isEnabled ? .black : .gray
    }
}

extension HabitTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 40, height: 40) // Фиксированный размер 52x52
       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 20 // Горизонтальный отступ между ячейками
       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 12 // Вертикальный отступ между рядами
       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Отступы секции
       }
}
