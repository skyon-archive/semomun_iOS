//
//  TestSubjectCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/08.
//

import UIKit

final class TestSubjectCell: UICollectionViewCell {
    static let identifer = "TestSubjectCell"
    static let cellSize: CGSize = CGSize(146, 240)
    
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // 임시용 로직
    func configure(title: String, price: String? = nil) {
        self.titleLabel.text = title
        self.priceLabel.text = price ?? ""
    }
    
}