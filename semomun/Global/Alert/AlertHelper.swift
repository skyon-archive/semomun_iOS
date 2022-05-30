//
//  AlertHelper.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/30.
//

import UIKit

class AlertHelper {
    static func showAlert(content: AlertContent, actions: [UIAlertAction], over viewController: UIViewController) {
        let ac = UIAlertController(title: content.title, message: content.message, preferredStyle: .alert)
        actions.forEach { ac.addAction($0) }
        viewController.present(ac, animated: true)
    }
}
