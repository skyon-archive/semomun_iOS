//
//  AreaRankCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/16.
//

import UIKit

final class TestRankCell: UICollectionViewCell {
    /* public */
    static let identifier = "TestRankCell"
    static let cellSize: CGSize = .init(110, 100)
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

extension TestRankCell {
    func prepareForReuse(info: TestResultInfoOfDB) {
        self.areaTitleLabel.text = info.subject
        self.areaRankLabel.text = "\(info.result.rank)"
    }
}
