//
//  CellLayoutable.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/15.
//

import UIKit

protocol CellLayoutable {
    static var identifier: String { get }
    static func topViewHeight(with problem: Problem_Core) -> CGFloat
}
