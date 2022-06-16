//
//  MultipleWithConceptCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithConceptCell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWithConceptCell"
    static func topViewHeight(with problem: Problem_Core) -> CGFloat {
        return 51
    }
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    /* private */
    private lazy var answerView = AnswerView()
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var topView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureTimerLayout()
    }

    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.configureStar()
    }
    
    override func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    override func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}

// MARK: Configure
extension MultipleWithConceptCell {
    private func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 9)
        ])
    }
}

// MARK: Update
extension MultipleWithConceptCell {
    private func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
}
