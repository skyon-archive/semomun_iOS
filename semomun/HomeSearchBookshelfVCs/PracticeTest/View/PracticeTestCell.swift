//
//  PracticeTestCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/08.
//

import UIKit

final class PracticeTestCell: UICollectionViewCell {
    static let identifer = "PracticeTestCell"
    
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
