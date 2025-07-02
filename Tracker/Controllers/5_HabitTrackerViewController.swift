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
                
            let colorViewSize: CGFloat = 40
            let xOffset = (cell.contentView.bounds.width - colorViewSize) / 2
            let yOffset = (cell.contentView.bounds.height - colorViewSize) / 2
             
            let colorView = UIView(frame: CGRect(x: xOffset, y: yOffset, width: colorViewSize, height: colorViewSize))
         
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
    private let scrollView = UIScrollView()
    
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
        setupCollections()
        
        setupButtonFalse()
        setupButtonCreate()
        
        setupConstraints()
        setupHideKeyboardOnTap()

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
        //view.addSubview(nameCollectionEmojiView)
        
        nameCollectionColorsView.text = "Цвет"
        nameCollectionColorsView.font = UIFont.boldSystemFont(ofSize: 19)
        nameCollectionColorsView.textColor = .black
        nameCollectionColorsView.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(nameCollectionColorsView)
        
    }
    
    private func setupCollections() {
        
        // Настройка ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Контейнер для контента внутри ScrollView
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Добавляем контент в contentView
        contentView.addSubview(nameCollectionEmojiView)
        contentView.addSubview(collectionEmoji)
        contentView.addSubview(nameCollectionColorsView)
        contentView.addSubview(collectionColors)
        
        NSLayoutConstraint.activate([
            
            // Констрейнты для contentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Контент внутри contentView
            nameCollectionEmojiView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            nameCollectionEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            collectionEmoji.topAnchor.constraint(equalTo: nameCollectionEmojiView.bottomAnchor, constant: 24),
            collectionEmoji.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionEmoji.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionEmoji.heightAnchor.constraint(equalToConstant: 156),
            
            nameCollectionColorsView.topAnchor.constraint(equalTo: collectionEmoji.bottomAnchor, constant: 24),
            nameCollectionColorsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            collectionColors.topAnchor.constraint(equalTo: nameCollectionColorsView.bottomAnchor, constant: 0),
            collectionColors.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionColors.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionColors.heightAnchor.constraint(equalToConstant: 180),
            collectionColors.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
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
    }

    private func setupCollectionColors() {
        collectionColors.delegate = self
        collectionColors.dataSource = self
        collectionColors.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellColors")
        collectionColors.backgroundColor = .clear
        collectionColors.layer.cornerRadius = 16
        collectionColors.isScrollEnabled = false
        collectionColors.allowsMultipleSelection = false
    }
    
    private func setupButtonFalse() {
        buttonFalse.setTitle("Отменить", for: .normal)
        buttonFalse.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonFalse.setTitleColor(.red, for: .normal)
        buttonFalse.backgroundColor = .white
        buttonFalse.layer.cornerRadius = 16
        buttonFalse.addTarget(self, action: #selector(falseButtonTapped), for: .touchUpInside)
        buttonFalse.layer.borderWidth = 1
        buttonFalse.layer.borderColor = UIColor.red.cgColor
        buttonFalse.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonFalse)
    }
    
    private func setupButtonCreate() {
        buttonCreate.setTitle("Создать", for: .normal)
        buttonCreate.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonCreate.setTitleColor(.white, for: .normal)
        buttonCreate.backgroundColor = UIColor(named: "grayMy")
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
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextFieldContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 38),
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
            tableView.topAnchor.constraint(equalTo: nameTextFieldContainer.bottomAnchor, constant: 24),
            
            tableView.leadingAnchor.constraint(equalTo: nameTextFieldContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: nameTextFieldContainer.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Кнопки
            buttonFalse.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonFalse.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonFalse.widthAnchor.constraint(equalToConstant: 160),
            buttonFalse.heightAnchor.constraint(equalToConstant: 60),
            
            buttonCreate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonCreate.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonCreate.widthAnchor.constraint(equalToConstant: 160),
            buttonCreate.heightAnchor.constraint(equalToConstant: 60),
            
            scrollView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            scrollView.bottomAnchor.constraint(equalTo: buttonFalse.topAnchor, constant: -16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
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
    
    @objc private func falseButtonTapped() {
        dismiss(animated: true)
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
            shedule: selectedDays,
            kind: .habit
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
    
    //выбор ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionEmoji {
            selectedEmoji = emojis[indexPath.row]
            // Подсвечиваем фон выбранной ячейки серым
            if let cell = collectionView.cellForItem(at: indexPath) {
                //cell.contentView.backgroundColor = .lightGray
                cell.contentView.backgroundColor = UIColor(named: "grayLight")
                cell.contentView.layer.cornerRadius = 16
            }
        } else {
            selectedColor = colors[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = UIColor(named: "colorSelection")?.cgColor
                cell.contentView.layer.cornerRadius = 8
            }
        }
        updateButtonCreateState()
    }
    
    //снятие выбора ячейки
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == collectionEmoji {
            // Сбрасываем фон при отмене выбора
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = .clear
            }
        } else {
            // Убираем рамку при отмене выбора
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.layer.borderWidth = 0
            }
        }
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
            return CGSize(width: 52, height: 52)

       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           //между ячейками
           return 0
  
       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           //между рядами
           return 0
      
       }
       
       func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
          //секции
           if collectionView == collectionEmoji {
                    return UIEdgeInsets(top: 0, left: 9, bottom: 24, right: 9)
               } else {
                   return UIEdgeInsets(top: 24, left: 9, bottom: 24, right: 9)
               }
       }
    
}
