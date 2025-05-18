//
//  UIViewController+Ext.swift
//  Tracker
//
//  Created by Захар Панченко on 18.05.2025.
//

import UIKit

extension UIViewController {
    
    func setupHideKeyboardOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
