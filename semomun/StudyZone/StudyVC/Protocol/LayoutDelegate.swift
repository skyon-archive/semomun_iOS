//
//  LayoutDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/27.
//

import Foundation

protocol LayoutDelegate: AnyObject {
    func reloadButtons()
    func showAlert(text: String)
    func dismissSection()
    func changeResultLabel()
}
