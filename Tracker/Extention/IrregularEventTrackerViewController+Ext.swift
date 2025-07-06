//
//  IrregularEventTrackerViewController+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 15.05.2025.
//

import UIKit

extension IrregularEventTrackerViewController: UITableViewDataSource, UITableViewDelegate, CategorySelectionDelegate, UITextFieldDelegate {
    
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
            }
            content.secondaryTextProperties.color = .gray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = tableData[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = selectedCategory ?? ""
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
        //Открыть страницу выбора Категории
        let choiceCategoryVC = ChoiceCategoryViewController()
        choiceCategoryVC.delegate = self
        self.present(choiceCategoryVC, animated: true)
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
        print("Выбрана категория: \(category)")
        selectedCategory = category
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateButtonCreateState()
    }
    
    func didSelectShedule(_ schedule: [WeekDay]) {
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateButtonCreateState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Текущий текст + нововведённый символ
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 38 {
            warningLabel.isHidden = false
            return false
        } else {
            warningLabel.isHidden = true
        }
        
        return true
    }
    
}
