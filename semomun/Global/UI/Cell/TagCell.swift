//
//  TagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit

class TagCell: UICollectionViewCell {
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel.text = ""
    }
    
    func configure(tag: String) {
        self.tagNameLabel.text = tag
    }
}
