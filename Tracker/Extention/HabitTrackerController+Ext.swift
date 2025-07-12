//
//  HabitTrackerController+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 30.04.2025.
//
import UIKit

extension HabitTrackerViewController: UITableViewDataSource, UITableViewDelegate, CategorySelectionDelegate, SheduleSelectionDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = tableData[indexPath.row]
            content.textProperties.font = UIFont.systemFont(ofSize: 17)
            content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 17)
            
            if indexPath.row == 0 {
                content.secondaryText = selectedCategory ?? ""
            } else {
                content.secondaryText = selectedDays.isEmpty ? "" : selectedDays.map { $0.shortName }.joined(separator: ", ")
            }
            content.secondaryTextProperties.color = .gray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = tableData[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = selectedCategory ?? ""
            } else {
                cell.detailTextLabel?.text = selectedDays.isEmpty ? "" : selectedDays.map { $0.shortName }.joined(separator: ", ")
            }
            
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        
        cell.backgroundColor = .systemGray6
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Высота каждой ячейки
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Обработка нажатия на ячейку
        if tableData[indexPath.row] == "Категория" {
            //Открыть страницу выбора Категории
            let choiceCategoryVC = ChoiceCategoryViewController()
            choiceCategoryVC.delegate = self
            self.present(choiceCategoryVC, animated: true)
            
        } else {
            let choiceSheduleVC = ChoiceSheduleViewController()
            choiceSheduleVC.delegate = self
            choiceSheduleVC.selectedDays = selectedDays
            self.present(choiceSheduleVC, animated: true)
        }
        
        print("Выбрано: \(tableData[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    //Блок для делегата
    func didSelectCategory(_ category: String) {
        print("Выбрана категория: \(category)") // Отладочная печать
        selectedCategory = category
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateButtonCreateState()
    }
    
    func didSelectShedule(_ schedule: [WeekDay]) {
        selectedDays = schedule
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateButtonCreateState()
    }
    
}
