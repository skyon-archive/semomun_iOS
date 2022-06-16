//
//  AreaRankCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/16.
//

import UIKit

class AreaRankCell: UICollectionViewCell {
    /* public */
    static let identifier = "AreaRankCell"
    /* private */
    @IBOutlet weak var roundedBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundedBackground.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.roundedBackground.addAccessibleShadow()
    }
}
