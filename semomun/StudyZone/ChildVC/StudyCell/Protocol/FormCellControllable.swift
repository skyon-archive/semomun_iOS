//
//  FormCellControllable.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/29.
//

import UIKit

protocol FormCellControllable: AnyObject {
    func refreshPageButtons()
    func addScoring(pid: Int)
    func addUpload(pid: Int)
}
