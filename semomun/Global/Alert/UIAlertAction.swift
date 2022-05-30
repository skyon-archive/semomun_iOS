//
//  UIAlertAction.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/30.
//

import UIKit

extension UIAlertAction {
    static var destructiveCancel: UIAlertAction {
        return .init(title: "취소", style: .destructive)
    }
    
    static var defaultCancel: UIAlertAction {
        return .init(title: "취소", style: .default)
    }
    
    static var destructiveConfirm: UIAlertAction {
        return .init(title: "확인", style: .destructive)
    }
    
    static var defaultConfirm: UIAlertAction {
        return .init(title: "확인", style: .default)
    }
}
