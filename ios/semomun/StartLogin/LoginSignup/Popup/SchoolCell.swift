//
//  SchoolCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

final class SchoolCell: UICollectionViewCell {
    static let identifier = "SchoolCell"
    static let cellHeight = CGFloat(48)
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkIcon.image = UIImage(systemName: "circle")
        self.checkIcon.tintColor = UIColor.getSemomunColor(.lightGray)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.checkIcon.image = UIImage(systemName: "circle")
        self.checkIcon.tintColor = UIColor.getSemomunColor(.lightGray)
    }
    
    func configure(name: String, currentSchoolName: String?) {
        self.schoolNameLabel.text = name
        if name == currentSchoolName {
            self.checkIcon.image = UIImage(systemName: "circle.inset.filled")
            self.checkIcon.tintColor = UIColor.getSemomunColor(.blueRegular)
        }
    }
}
