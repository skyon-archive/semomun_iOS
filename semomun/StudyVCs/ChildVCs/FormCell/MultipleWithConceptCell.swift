//
//  MultipleWithConceptCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithConceptCell: FormCell, CellLayoutable {
    static let identifier = "MultipleWithConceptCell"
    static func topViewHeight(with problem: Problem_Core) -> CGFloat {
        return 51
    }
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var topView: UIView!
    
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureTimerLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timerView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        if self.showTopShadow {
            self.addTopShadow()
        } else {
            self.removeTopShadow()
        }
    }

    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.configureUI()
    }
    
    // MARK: Configure
    private func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 9)
        ])
    }
    
    private func configureUI() {
        self.configureStar()
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
}

extension MultipleWithConceptCell {
    func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}

