//
//  AreaRankCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/16.
//

import UIKit

final class TestSubjectRankCell: UICollectionViewCell {
    /* public */
    static let identifier = "TestSubjectRankCell"
    static let cellSize: CGSize = .init(100, 100)
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

extension TestSubjectRankCell {
    func prepareForReuse(info: PublicTestResultInfoOfDB) {
        self.areaTitleLabel.text = info.subject
        self.areaRankLabel.text = "\(info.rank)"
    }
}
