//
//  MultipleWithNoAnswerCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithNoAnswerCell: FormCell, CellLayoutable {
    static let identifier = "MultipleWithNoAnswerCell"
    static func topViewHeight(with problem: Problem_Core) -> CGFloat {
        return 51
    }
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
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
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.showExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    override func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.configureReuse(contentImage, problem, toolPicker)
        self.configureUI()
    }
    
    // MARK: Configure
    private func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
    }
    
    private func configureUI() {
        self.configureStar()
        self.configureExplanationBT()
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    private func configureExplanationBT() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
}

extension MultipleWithNoAnswerCell {
    func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}
