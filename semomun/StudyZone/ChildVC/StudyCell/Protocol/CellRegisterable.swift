//
//  CellRegisterable.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/26.
//

import UIKit

protocol CellRegisterable: UICollectionViewCell {
    static var identifier: String { get }
}
