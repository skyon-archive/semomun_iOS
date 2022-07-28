//
//  ShortTextCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit
import PencilKit

final class ShortTextCell: FormCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "ShortTextCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        guard let problem = problem, problem.terminated == true else {
            return StudyShortTextAnswerView.size(terminated: false, isCorrect: false).height+16
        }
        return StudyShortTextAnswerView.size(terminated: true, isCorrect: problem.correct).height+16
    }
    override var internalTopViewHeight: CGFloat {
        return Self.topViewHeight(with: self.problem)
    }
    /* private */
    private let answerView = StudyShortTextAnswerView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.answerView.configureDelegate(delegate: self)
        self.answerView.textField.addTarget(self, action: #selector(updateAnswer), for: .editingChanged)
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
extension ShortTextCell {
    private func updateCorrectImage() {
        guard let problem = self.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension ShortTextCell {
    private func updateAnswerViewFrame() {
        guard let terminated = self.problem?.terminated,
              let correct = self.problem?.correct else { return }
        
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = StudyShortTextAnswerView.size(terminated: terminated, isCorrect: correct)
        let rightMargin: CGFloat = UIWindow.isLandscape ? 32 : 16
        self.answerView.frame = CGRect(origin: CGPoint(rightCorner.x - rightMargin - size.width, rightCorner.y + 16), size: size)
    }
    
    private func updateAnswerView() {
        guard let problem = self.problem else { return }
        let userAnswer = problem.solved
        self.answerView.configureUserAnswer(userAnswer)
        
        guard problem.terminated == true, let answer = problem.answer else { return }
        self.answerView.terminate(answer: answer, userAnswer: userAnswer)
    }
}

extension ShortTextCell: AnswerViewDelegate {
    func selectAnswer(to answer: String) {
        self.updateSolved(input: answer)
    }
}

extension ShortTextCell: UITextFieldDelegate {
    @objc private func updateAnswer() {
        if let text = self.answerView.textField.text {
            self.selectAnswer(to: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateAnswer()
        textField.resignFirstResponder()
        return true
    }
}
