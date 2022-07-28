//
//  RemoveableCategoryTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/28.
//

import UIKit

final class RemoveableCategoryTagCell: UICollectionViewCell {
    static let identifier = "RemoveableCategoryTagCell"
    static func size(categoryName: String, tagName: String) -> CGSize {
        let stackViewInnerSpacing = CGFloat(8)
        let slashWidth = CGFloat(5.5)
        let leftMargin = CGFloat(16)
        let rightMargin = CGFloat(40)
        
        let categoryWidth = NSMutableAttributedString(string: categoryName, attributes:[
            NSAttributedString.Key.font: UIFont.heading5
        ]).size().width
        let nameWidth = NSMutableAttributedString(string: tagName, attributes:[
            NSAttributedString.Key.font: UIFont.heading5
        ]).size().width
        
        return .init(stackViewInnerSpacing + slashWidth + leftMargin + rightMargin + categoryWidth + nameWidth, 32)
    }
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var xIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.xIcon.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
    }
    
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
