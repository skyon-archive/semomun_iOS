//
//  FavoriteCategoryCell.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/11.
//

import UIKit

class FavoriteCategoryCell: UICollectionViewCell {
    static let identifier = "FavoriteCategoryCell"
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 5
        self.contentView.backgroundColor = UIColor.white
        self.title.textColor = UIColor.black
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.diSelected()
        self.title.text = ""
    }
    
    func configure(title: String) {
        self.title.text = title
    }
    
    func didSelected() {
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.backgroundColor = UIColor(named: "mint")
        self.title.textColor = UIColor.white
    }
    
    func diSelected() {
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.backgroundColor = UIColor.white
        self.title.textColor = UIColor.black
    }
}
