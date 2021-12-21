//
//  CategoryCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/16.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    @IBOutlet var category: UILabel!
    @IBOutlet var underLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.underLine.layer.cornerRadius = 1.5
    }
}
