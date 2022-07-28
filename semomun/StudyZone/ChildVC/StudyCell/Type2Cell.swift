//
//  Type2Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit
import PencilKit

final class Type2Cell: StudyCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "Type2Cell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return Study2AnswerView.size.height+16
    }
    override var internalTopViewHeight: CGFloat {
        return Study2AnswerView.size.height+16
    }
    /* private */
    private let answerView = Study2AnswerView()
    
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
extension Type2Cell {
    private func updateCorrectImage() {
        guard let problem = self.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension Type2Cell {
    private func updateAnswerViewFrame() {
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = Study2AnswerView.size
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

extension Type2Cell: AnswerViewDelegate {
    func selectAnswer(to answer: String) {
        self.updateSolved(input: answer)
    }
}
