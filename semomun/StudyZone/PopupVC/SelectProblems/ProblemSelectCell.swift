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
            self.terminatedUI()
        } else if isChecked {
            self.checkedUI()
        } else {
            self.unCheckedUI()
        }
    }
}

extension ProblemSelectCell {
    private func unCheckedUI() {
        self.contentView.backgroundColor = .white
        self.contentView.layer.borderColor = UIColor(.blueRegular)?.cgColor
        self.title.textColor = UIColor(.blueRegular)
    }
    
    private func checkedUI() {
        self.contentView.backgroundColor = UIColor(.blueRegular)
        self.contentView.layer.borderColor = UIColor(.blueRegular)?.cgColor
        self.title.textColor = .white
    }
    
    private func terminatedUI() {
        self.contentView.backgroundColor = UIColor(.lightGray)
        self.contentView.layer.borderColor = UIColor(.lightGray)?.cgColor
        self.title.textColor = .white
    }
}
