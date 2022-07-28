//
//  CategoryTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/28.
//

import UIKit

final class CategoryTagCell: UICollectionViewCell {
    static let identifier = "CategoryTagCell"
    static let stackViewInnerSpacing = CGFloat(8)
    static let slashWidth = CGFloat(5.5)
    static var horizontalInset: CGFloat {
        return Self.stackViewInnerSpacing + Self.slashWidth
    }
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.categoryNameLabel.text = ""
        self.tagNameLabel.text = ""
    }
    
    func configure(category: String, tag: String) {
        self.categoryNameLabel.text = category
        self.tagNameLabel.text = tag
    }
}
