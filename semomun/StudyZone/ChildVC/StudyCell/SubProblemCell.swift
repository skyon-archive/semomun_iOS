//
//  SubProblemCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

final class SubProblemCell: StudyCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "SubProblemCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        let problemCount = problem?.subProblemsCount ?? 0
        guard let problem = problem, problem.terminated == true else {
            return StudySubProblemsAnswerView.size(terminated: false, problemCount: Int(problemCount), wrongCount: 0).height + 16
        }
        
        let wrongCount = StudySubProblemsAnswerView.wrongCount(problem: problem)
        return StudySubProblemsAnswerView.size(terminated: true, problemCount: Int(problemCount), wrongCount: wrongCount).height + 16
    }
    override var internalTopViewHeight: CGFloat {
        return Self.topViewHeight(with: self.problem)
    }
    
    /* private */
    private let answerView = StudySubProblemsAnswerView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.answerView.configureDelegate(delegate: self)
        self.contentView.addSubview(self.answerView)
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        super.prepareForReuse(contentImage, problem, toolPicker)

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
extension SubProblemCell {
    private func updateCorrectImage() {
        guard let problem = self.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension SubProblemCell {
    private func updateAnswerViewFrame() {
        guard let problem = self.problem else { return }
        let terminated = problem.terminated
        let problemCount = Int(problem.subProblemsCount)
        let wrongCount = StudySubProblemsAnswerView.wrongCount(problem: problem)
        
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = StudySubProblemsAnswerView.size(terminated: terminated, problemCount: problemCount, wrongCount: wrongCount)
        let rightMargin: CGFloat = UIWindow.isLandscape ? 32 : 16
        self.answerView.frame = CGRect(origin: CGPoint(rightCorner.x - rightMargin - size.width, rightCorner.y + 16), size: size)
    }
    
    private func updateAnswerView() {
        guard let problem = self.problem else { return }
        self.answerView.configureUserAnswer(problem: problem)
        
        guard problem.terminated == true else { return }
        self.answerView.terminate()
    }
}

extension SubProblemCell: SubproblemsAnswerViewDelegate {
    func selectAnswer(to answer: String) {
        // userAnswer 저장
        self.updateSolved(input: answer)
        // answer, userAnwer 비교 후 score 계산
        guard let problem = self.problem else { return }
        let wrongCount = StudySubProblemsAnswerView.wrongCount(problem: problem)
        let correctCount = Int(problem.subProblemsCount) - wrongCount
        problem.setValue(Int64(correctCount), forKey: Problem_Core.Attribute.correctPoints.rawValue)
        print("answer: \(answer), score: \(correctCount)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.answerView.changeToNextTextField()
        self.answerView.saveUserAnswer()
        return true
    }
}
