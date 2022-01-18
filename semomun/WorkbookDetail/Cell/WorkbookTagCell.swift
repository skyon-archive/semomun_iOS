//
//  WorkbookTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/18.
//

import UIKit

class WorkbookTagCell: UICollectionViewCell {
    static let identifier = "WorkbookTagCell"
    
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel.text = "#"
    }
    
    func configure(tag: String) {
        self.tagNameLabel.text = "#\(tag)"
    }
}
