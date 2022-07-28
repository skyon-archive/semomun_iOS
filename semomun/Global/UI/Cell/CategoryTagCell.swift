//
//  CategoryTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/28.
//

import UIKit

final class CategoryTagCell: UICollectionViewCell {
    static let identifier = "CategoryTagCell"
    static func size(categoryName: String, tagName: String) -> CGSize {
        let stackViewInnerSpacing = CGFloat(8)
        let slashWidth = CGFloat(5.5)
        let horizontalMargin = CGFloat(32)
        
        let categoryWidth = NSMutableAttributedString(string: categoryName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.darkGray),
            NSAttributedString.Key.font: UIFont.heading4
        ]).size().width
        let nameWidth = NSMutableAttributedString(string: tagName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.black),
            NSAttributedString.Key.font: UIFont.heading4
        ]).size().width
        
        return .init(stackViewInnerSpacing + slashWidth + horizontalMargin + categoryWidth + nameWidth, 32)
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
