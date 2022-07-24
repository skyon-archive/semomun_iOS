//
//  ProblemCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/24.
//

import UIKit

final class ProblemCell: UICollectionViewCell {
    static let identifier = "ProblemCell"
    static let correctColor = UIColor.systemGreen
    static let wrongColor = UIColor.systemRed
    static let defaultTitleColor = UIColor.getSemomunColor(.black)
    static let selectedTitleColor = UIColor.getSemomunColor(.background)
    static let borderDefaultColor = UIColor.getSemomunColor(.border)
    static let bookmarkDefaultColor = UIColor.getSemomunColor(.lightGray)
    
    @IBOutlet weak var problemNameLabel: UILabel!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.problemNameLabel.textColor = UIColor.getSemomunColor(.background)
        self.contentView.backgroundColor = UIColor.getSemomunColor(.background)
        self.contentView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
    }
}

extension ProblemCell {
    func configure(problem: Problem_Core, isSelected: Bool) {
        self.problemNameLabel.text = problem.pName ?? "-"
        self.configureBorderColor(terminated: problem.terminated, correct: problem.correct)
        self.configureTitleColor(isSelected: isSelected)
        self.configureBackgroundColor(terminated: problem.terminated, correct: problem.correct, isSelected: isSelected)
        self.configureBookmarkColor(notHidden: problem.star, terminated: problem.terminated, correct: problem.correct, isSelected: isSelected)
    }
    
    private func configureBorderColor(terminated: Bool, correct: Bool) {
        guard terminated == true else {
            self.contentView.layer.borderColor = Self.borderDefaultColor.cgColor
            return
        }
        
        self.contentView.layer.borderColor = correct ? Self.correctColor.cgColor : Self.wrongColor.cgColor
    }
    
    private func configureTitleColor(isSelected: Bool) {
        self.problemNameLabel.textColor = isSelected ? Self.defaultTitleColor : Self.selectedTitleColor
    }
    
    private func configureBackgroundColor(terminated: Bool, correct: Bool, isSelected: Bool) {
        guard terminated == true else {
            self.contentView.backgroundColor = isSelected ? Self.defaultTitleColor : Self.selectedTitleColor
            return
        }
        
        guard isSelected == true else {
            self.contentView.backgroundColor = Self.selectedTitleColor
            return
        }
        
        self.contentView.backgroundColor = correct ? Self.correctColor : Self.wrongColor
    }
    
    private func configureBookmarkColor(notHidden: Bool, terminated: Bool, correct: Bool, isSelected: Bool) {
        self.bookmarkIcon.isHidden = !notHidden
        guard notHidden == true else { return }
        
        guard terminated == true else {
            self.bookmarkIcon.setSVGTintColor(to: isSelected ? Self.selectedTitleColor : Self.bookmarkDefaultColor)
            return
        }
        
        guard isSelected == true else {
            self.bookmarkIcon.setSVGTintColor(to: correct ? Self.correctColor : Self.wrongColor)
            return
        }
        
        self.bookmarkIcon.setSVGTintColor(to: Self.selectedTitleColor)
    }
}

// default + deSelected
// default + bookmark + deSelected
// default + selected
// default + bookmark + selected
// terminated + wrong + deSelected
// terminated + wrong + bookmark + deSelected
// terminated + wrong + selected
// terminated + wrong + bookmark + selected
// terminated + correct + deSelected
// terminated + correct + bookmark + deSelected
// terminated + correct + selected
// terminated + correct + bookmark + selected

