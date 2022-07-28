//
//  RemoveableTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/11.
//

import UIKit

final class RemoveableTagCell: UICollectionViewCell {
    static let identifier = "RemoveableTagCell"
    static let horizontalMargin: CGFloat = 16 + 40 // left margin + xMark 영역을 포함한 right margin
    static func makeAttributedText(categoryName: String, tagName: String) -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(NSMutableAttributedString(string: categoryName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.darkGray),
            NSAttributedString.Key.font: UIFont.heading4
        ]))
        text.append(NSMutableAttributedString(string: " / ", attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.lightGray),
            NSAttributedString.Key.font: UIFont.heading5
        ]))
        text.append(NSMutableAttributedString(string: tagName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.black),
            NSAttributedString.Key.font: UIFont.heading4
        ]))
        return text
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
    
    func configure(categoryName: String, tagName: String) {
        self.tagNameLabel.attributedText = Self.makeAttributedText(categoryName: categoryName, tagName: tagName)
    }
}
