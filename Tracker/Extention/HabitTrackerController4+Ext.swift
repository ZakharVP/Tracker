//
//  Untitled.swift
//  Tracker
//
//  Created by Захар Панченко on 30.04.2025.
//

import UIKit

extension HabitTrackerViewController: UITextFieldDelegate {
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
