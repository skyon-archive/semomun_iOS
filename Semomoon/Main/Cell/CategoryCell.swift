//
//  CategoryCell.swift
//  Semomoon
//
//  Created by qwer on 2021/10/16.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    @IBOutlet var category: UILabel!
    @IBOutlet var underLine: UIView!
    
    func setRadiusOfUnderLine() {
        self.underLine.layer.cornerRadius = 1.5
    }
}
