//
//  ProblemSelectCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import UIKit

final class ProblemSelectCell: UICollectionViewCell {
    static let identifier = "ProblemSelectCell"
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.unCheckedUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.unCheckedUI()
    }
    
    func configure(problem: Problem_Core, isChecked: Bool) {
        self.title.text = problem.pName
        if problem.terminated {
            if problem.correct == true {
                self.correctUI()
            } else {
                self.wrongUI()
            }
        } else if isChecked {
            self.checkedUI()
        } else {
            self.unCheckedUI()
        }
    }
}

extension ProblemSelectCell {
    private func unCheckedUI() {
        self.contentView.backgroundColor = UIColor.getSemomunColor(.background)
        self.title.textColor = UIColor.getSemomunColor(.black)
        self.contentView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
    }
    
    private func checkedUI() {
        self.contentView.backgroundColor = UIColor.getSemomunColor(.black)
        self.title.textColor = UIColor.getSemomunColor(.white)
        self.contentView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
    }
    
    private func correctUI() {
        self.unCheckedUI()
        self.contentView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    private func wrongUI() {
        self.contentView.layer.borderColor = UIColor.systemRed.cgColor
    }
}
