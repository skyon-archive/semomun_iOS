//
//  StartTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/23.
//

import UIKit

class StartTagCell: UICollectionViewCell {
    static let identifier = "StartTagCell"
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
        self.contentView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.deSelect()
        self.title.text = ""
    }
    
    func configure(title: String) {
        self.title.text = title
    }
    
    func didSelect() {
        self.contentView.backgroundColor = UIColor(named: SemomunColor.mainColor)
        self.title.textColor = UIColor.white
        self.title.font = UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    
    func deSelect() {
        self.contentView.backgroundColor = .white
        self.title.textColor = UIColor(named: SemomunColor.mainColor)
        self.title.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
}
