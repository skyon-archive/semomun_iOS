//
//  WrongProblemCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/24.
//

import UIKit

class WrongProblemCell: UICollectionViewCell {
    static let identifier = "WrongProblemCell"
    
    @IBOutlet var problemNumber: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.problemNumber.text = ""
    }
    
    func configure(to number: String) {
        self.problemNumber.text = number
    }
}
