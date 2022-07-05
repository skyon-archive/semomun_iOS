//
//  SmallTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit

class SmallTagCell: UICollectionViewCell {
    static let identifier = "SmallTagCell"
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(.blueRegular)?.cgColor
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = UIDevice.current.userInterfaceIdiom == .phone ? 13.5 : 15
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
    }
    
    func configure(tag: String) {
        self.title.text = "#\(tag)"
    }
}
