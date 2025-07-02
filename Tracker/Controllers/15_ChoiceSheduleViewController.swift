//
//  ChoiceSheduleViewController.swift
//  Tracker
//
//  Created by Захар Панченко on 03.05.2025.
//

import UIKit

class ChoiceSheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDayWeek = tableView.dequeueReusableCell(withIdentifier: "cellDayWeek", for: indexPath)
        cellDayWeek.textLabel?.text = tableData[indexPath.row]
        cellDayWeek.backgroundColor = .systemGray6
        cellDayWeek.selectionStyle = .none
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.onTintColor = .blue
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        let day = WeekDay.allCases[indexPath.row]
        switchView.isOn = selectedDays.contains(day)
        
        cellDayWeek.accessoryView = switchView
        
        return cellDayWeek
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        if indexPath.row == tableData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private let nameLabel = UILabel()
    private let tableView = UITableView()
    private let doneButton = UIButton()
    
    private let tableData = ["Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"]
    var selectedDays: [WeekDay] = []
    
    weak var delegate: SheduleSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNameLabel()
        setupTableView()
        setupDoneButton()
        setupConstraints()
        
    }
    
    private func setupNameLabel() {
        nameLabel.text = "Выберите день недели"
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellDayWeek")
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        
        view.addSubview(tableView)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
 
            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            //tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47),
            
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
        
    }
    
    @objc private func doneButtonTapped() {
        print("Выбранные дни: \(selectedDays)")
        delegate?.didSelectShedule(selectedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        
        if sender.isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
            }
        } else {
            selectedDays.removeAll() { $0 == day }
        }
    }
    
}

