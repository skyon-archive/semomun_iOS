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
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "mainColor")!.cgColor
        self.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.majorName.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isSelected {
            self.backgroundColor = UIColor(named: "mainColor")
            self.majorName.textColor = .white
        } else {
            self.backgroundColor = .white
            self.majorName.textColor = UIColor(named: "mainColor")!
        }
    }
    
    func configureText(major: String) {
        self.majorName.text = major
    }
}
