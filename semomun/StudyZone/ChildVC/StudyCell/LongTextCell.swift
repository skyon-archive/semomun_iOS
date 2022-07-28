//
//  LongTextCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit
import PencilKit

final class LongTextCell: StudyCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "LongTextCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return StudyLongTextAnswerView.size.height+16
    }
    override var internalTopViewHeight: CGFloat {
        return StudyLongTextAnswerView.size.height+16
    }
    /* private */
    private let answerView = StudyLongTextAnswerView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.answerView.configureDelegate(delegate: self)
        self.contentView.addSubview(self.answerView)
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = nil) {
        super.prepareForReuse(contentImage, problem, toolPicker, mode)
        
        self.toolbarView.updateUI(mode: self.mode, problem: problem, answer: self.problem?.answer ?? "")
        
        self.updateAnswerView()
        self.updateCorrectImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateAnswerViewFrame()
    }
}

// MARK: Update
extension LongTextCell {
    private func updateCorrectImage() {
        guard let problem = self.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension LongTextCell {
    private func updateAnswerViewFrame() {
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = StudyLongTextAnswerView.size
        let rightMargin: CGFloat = UIWindow.isLandscape ? 32 : 16
        self.answerView.frame = CGRect(origin: CGPoint(rightCorner.x - rightMargin - size.width, rightCorner.y + 16), size: size)
    }
    
    private func updateAnswerView() {
        self.answerView.configureUserAnswer(self.problem?.solved)
        guard self.problem?.terminated == true else { return }
        self.answerView.terminate()
    }
}

// MARK: AnswerView
extension LongTextCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = self.answerView.textView.text {
            self.updateSolved(input: text)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == StudyLongTextAnswerView.placeholderTextColor {
            textView.text = ""
            textView.textColor = UIColor.getSemomunColor(.black)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = StudyLongTextAnswerView.placeholderTextColor
            textView.text = StudyLongTextAnswerView.placeHolder
        }
    }
}
