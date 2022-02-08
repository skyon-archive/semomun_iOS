//
//  CollectionCellDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/29.
//

import UIKit

protocol CollectionCellDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func showExplanation(image: UIImage?, pid: Int)
    func updateWrong(btName: String, to: Bool)
}

protocol CollectionCellWithNoAnswerDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func updateCheck(btName: String)
    func nextPage()
}
