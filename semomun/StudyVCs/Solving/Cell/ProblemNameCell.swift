//
//  ProblemNameCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit

class ProblemNameCell: UICollectionViewCell {
    static let identifier = "ProblemNameCell"
    
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    private func resetUI() {
        self.contentView.backgroundColor = .white
        self.num.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        self.num.textColor = UIColor(.grayDefaultColor)
        self.num.text = ""
        self.checkImageView.isHidden = true
    }
    
    func configure(to num: String, isStar: Bool, isTerminated: Bool, isWrong: Bool, isChecked: Bool, isCurrent: Bool) {
        self.num.text = num
        
        if isStar {
            self.checkImageView.isHidden = false
        }
        
        if isTerminated {
            self.contentView.layer.borderColor = UIColor.clear.cgColor
            if isWrong {
                self.contentView.backgroundColor = UIColor(.redWrongColor)
                self.num.textColor = .white
            } else {
                self.contentView.backgroundColor = UIColor(.lightMainColor)
                self.num.textColor = UIColor(.deepMint)
            }
            if isCurrent {
                self.num.font = UIFont.systemFont(ofSize: 18, weight: .black)
            }
            return
        }
        
        if isChecked {
            self.num.textColor = UIColor(.mainColor)
            self.contentView.layer.borderColor = UIColor(.mainColor)?.cgColor
        } else {
            self.num.textColor = UIColor(.grayDefaultColor)
            self.contentView.layer.borderColor = UIColor(.grayDefaultColor)?.cgColor
        }
        
        if isCurrent {
            self.num.font = UIFont.systemFont(ofSize: 18, weight: .black)
            if !isChecked {
                self.num.textColor = .black
                self.contentView.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
}
