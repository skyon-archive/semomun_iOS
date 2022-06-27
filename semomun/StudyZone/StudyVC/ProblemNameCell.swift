//
//  ProblemNameCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit

class ProblemNameCell: UICollectionViewCell {
    static let identifier = "ProblemNameCell"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var bookmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    private func resetUI() {
        self.frameView.layer.borderColor = UIColor(.semoGray)?.cgColor
        self.frameView.layer.borderWidth = 1
        self.frameView.transform = CGAffineTransform.identity
        self.bookmark.isHidden = true
        self.num.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        self.num.textColor = UIColor(.semoGray)
        self.num.text = ""
    }
    
    func configure(problem: Problem_Core, isCurrent: Bool) {
        self.num.text = problem.pName ?? "-"
        
        if problem.star {
            self.bookmark.isHidden = false
        }
        
        let isWrong = problem.correct == false && problem.terminated
        if problem.terminated {
            self.frameView.layer.borderWidth = 2
            self.num.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            if isWrong {
                self.frameView.layer.borderColor = UIColor(.munRedColor)?.cgColor
                self.num.textColor = UIColor(.munRedColor)
            } else {
                self.frameView.layer.borderColor = UIColor(.deepMint)?.cgColor
                self.num.textColor = UIColor(.deepMint)
            }
        }
        
        if isCurrent {
            self.frameView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
}
