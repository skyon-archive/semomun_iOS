//
//  TagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit

final class TagCell: UICollectionViewCell {
    static let identifier = "TagCell"
    
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel.text = ""
    }
    
    func configure(tag: String) {
        self.tagNameLabel.text = tag
    }
    
    static func size(text: String) -> CGSize {
        let width = NSMutableAttributedString(string: text, attributes:[
            NSAttributedString.Key.font: UIFont.heading5
        ]).size().width + 32
        return .init(width, 32)
    }
}
