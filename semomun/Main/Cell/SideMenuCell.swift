//
//  SideMenuCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/28.
//

import UIKit

class SideMenuCell: UITableViewCell {
    static let identifier = "SideMenuCell"
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8
        self.contentView.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = .white
    }
    
    func configure(to title: String, isSelected: Bool) {
        self.title.text = title
        if isSelected {
            self.contentView.backgroundColor = UIColor(named: SemomunColor.selectCellColor)
        }
        self.configureDumyImageView(with: title)
    }
    
    private func configureDumyImageView(with title: String) {
        var iconName: String = "none"
        switch title {
        case "수능 및 모의고사":
            iconName = "suneung"
        case "LEET":
            iconName = "LEET"
        case "공인회계사":
            iconName = "cpa"
        case "공인중개사":
            iconName = "lrea"
        case "9급 공무원":
            iconName = "gosi"
        default:
            iconName = "none"
        }
        self.iconImageView.image = UIImage(named: iconName)
    }
}
