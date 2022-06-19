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
    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var areaRankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundedBackground.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.roundedBackground.addAccessibleShadow(direction: .bottom, shadowRadius: 4)
    }
}

extension AreaRankCell {
    func prepareForReuse(areaTitle: String, areaRank: Int) {
        self.areaTitleLabel.text = areaTitle
        self.areaRankLabel.text = "\(areaRank)"
    }
}