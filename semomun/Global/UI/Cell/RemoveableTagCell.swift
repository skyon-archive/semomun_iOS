//
//  RemoveableTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/11.
//

import UIKit

final class RemoveableTagCell: UICollectionViewCell {
    static let identifier = "RemoveableTagCell"
    static let horizontalMargin: CGFloat = 16 + 40
    
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
