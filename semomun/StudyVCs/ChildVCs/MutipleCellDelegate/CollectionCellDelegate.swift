//
//  CollectionCellDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/29.
//

import UIKit

protocol CollectionCellDelegate: AnyObject {
    func reload()
    func selectExplanation(image: UIImage?, pid: Int)
    func addScoring(pid: Int)
    func addUpload(pid: Int)
}
