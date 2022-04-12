//
//  WorkbookInfoCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/04/12.
//

import UIKit

class WorkbookInfoCell: UICollectionViewCell {
    static let identifier = "WorkbookInfoCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.textLabel.text = ""
        self.separator.isHidden = false
    }
    
    func configure(title: String, text: String) {
        self.titleLabel.text = title
        self.textLabel.text = text
    }
    
    func hideSeparator() {
        self.separator.isHidden = true
    }
}
