//
//  RemoveableCategoryTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/28.
//

import UIKit

final class RemoveableCategoryTagCell: UICollectionViewCell {
    static let identifier = "RemoveableCategoryTagCell"
    static func size(tagName: String) -> CGSize {
        let leftMargin = CGFloat(16)
        let rightMargin = CGFloat(40)
        
        let nameWidth = NSMutableAttributedString(string: tagName, attributes:[
            NSAttributedString.Key.font: UIFont.heading5
        ]).size().width
        
        return .init(leftMargin + rightMargin + nameWidth, 32)
    }
    
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var xIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.xIcon.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel.text = ""
    }
    
    func configure(tag: String) {
        self.tagNameLabel.text = tag
    }
}
