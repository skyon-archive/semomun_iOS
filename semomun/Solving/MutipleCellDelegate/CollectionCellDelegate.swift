//
//  CollectionCellDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/29.
//

import UIKit

protocol CollectionCellDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func nextPage()
    func showExplanation(image: UIImage?)
    func updateWrong(btName: String, to: Bool)
}
