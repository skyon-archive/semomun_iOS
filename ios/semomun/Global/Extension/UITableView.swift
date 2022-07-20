//
//  UITableView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/28.
//

import UIKit

extension UITableView {
    func setHorizontalMargin(to margin: CGFloat) {
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin)
    }
}
