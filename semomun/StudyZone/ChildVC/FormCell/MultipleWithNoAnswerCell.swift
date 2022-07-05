//
//  MultipleWithNoAnswerCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithNoAnswerCell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWithNoAnswerCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return 51
    }
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    /* private */
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var topView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureTimerLayout()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.selectExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.updateStar()
        self.updateExplanationBT()
    }
    
    // MARK: override 구현
    override func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
    }
    
    override func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    override func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}

// MARK: Update
extension MultipleWithNoAnswerCell {
    private func updateStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isSelected = false
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanationBT.isUserInteractionEnabled = true
            self.explanationBT.setTitleColor(UIColor(.blueRegular), for: .normal)
        }
    }
}
