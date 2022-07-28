//
//  Form5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

final class Form5Cell: FormCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "Form5Cell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return Study5AnswerView.size.height+16
    }
    override var internalTopViewHeight: CGFloat {
        return Study5AnswerView.size.height+16
    }
    /* private */
    private let answerView = Study5AnswerView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.answerView.configureDelegate(delegate: self)
        self.contentView.addSubview(self.answerView)
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode?) {
        super.prepareForReuse(contentImage, problem, toolPicker, mode)
        
        let answer = self.problem?.answer?.split(separator: "$").joined(separator: ", ")
        self.toolbarView.updateUI(mode: self.mode, problem: problem, answer: answer)
        
        self.updateAnswerView()
        self.updateCorrectImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateAnswerViewFrame()
    }
}

// MARK: Update
extension Form5Cell {
    private func updateCorrectImage() {
        guard let problem = self.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension Form5Cell {
    private func updateAnswerViewFrame() {
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = Study5AnswerView.size
        let rightMargin: CGFloat = UIWindow.isLandscape ? 32 : 16
        self.answerView.frame = CGRect(origin: CGPoint(rightCorner.x - rightMargin - size.width, rightCorner.y + 16), size: size)
    }
    
    private func updateAnswerView() {
        guard let problem = self.problem else { return }
        let userAnswer = problem.solved != nil ? [problem.solved!] : []
        let terminated = problem.terminated
        self.answerView.configureUserAnswer(userAnswer, terminated, shouldMultipleAnswer: false)
        
        guard terminated == true, let answer = problem.answer else { return }
        self.answerView.terminate(answer: [answer], userAnswer: userAnswer)
    }
}

extension Form5Cell: AnswerViewDelegate {
    func selectAnswer(to answer: String) {
        self.updateSolved(input: answer)
    }
}
