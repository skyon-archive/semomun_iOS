//
//  MajorCollectionViewCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

class MajorCollectionViewCell: UICollectionViewCell {
    static let identifier = "MajorCollectionViewCell"
    
    @IBOutlet weak var majorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureUI(major: "", isSelected: false)
    }
    
    func configureUI(major: String, isSelected: Bool) {
        self.majorName.text = major
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "mainColor")!.cgColor
        self.layer.cornerRadius = 5
        if isSelected {
            self.backgroundColor = UIColor(named: "mainColor")
            self.majorName.textColor = .white
        } else {
            self.backgroundColor = .white
            self.majorName.textColor = UIColor(named: "mainColor")!
        }
    }
}
