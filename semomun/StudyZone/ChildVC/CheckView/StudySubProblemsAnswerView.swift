//
//  StudySubProblemsAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/26.
//

import UIKit

final class StudySubProblemsAnswerView: UIView {
    /* public */
    static let korLabels = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ"]
    static let EngLabels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    static let engLabels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    static let stackViewTopMargin = CGFloat(20)
    static let stackViewBottomMargin = CGFloat(8)
    static let subProblemHeight = CGFloat(33)
    static let stackViewSpacing = CGFloat(4)
    static let answerLabelHeight = CGFloat(22)
    static func size(terminated: Bool, problemCount: Int, wrongCount: Int) -> CGSize {
        if terminated == false {
            let heightMargin = Self.stackViewTopMargin + Self.stackViewBottomMargin
            let stackViewHeight = CGFloat(problemCount)*Self.subProblemHeight + CGFloat(problemCount-1)*Self.stackViewSpacing
            return CGSize(200, heightMargin + stackViewHeight)
        } else {
            let heightMargin = Self.stackViewTopMargin + Self.stackViewBottomMargin
            let stackViewHeight = CGFloat(problemCount)*Self.subProblemHeight + CGFloat(problemCount-1)*Self.stackViewSpacing
            let answerLabelHeights = CGFloat(wrongCount)*Self.answerLabelHeight
            return CGSize(200, heightMargin + stackViewHeight + answerLabelHeights)
        }
    }
    /* prvate */
    private weak var delegate: AnswerCheckDelegate?
    private var topBar = StudyAnswerViewTopBar()
    private var answersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    private var terminated: Bool = false
    private var subProblems: [StudySubProblemInputView] = []
    
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
        self.configureLayout()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.layer.cornerRadius = CGFloat.cornerRadius12
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
    }
    
    private func configureLayout() {
        self.addSubview(self.topBar)
        NSLayoutConstraint.activate([
            self.topBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.topBar.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.addSubview(self.answersStackView)
        NSLayoutConstraint.activate([
            self.answersStackView.topAnchor.constraint(equalTo: self.topBar.bottomAnchor, constant: 8),
            self.answersStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.answersStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.answersStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}

extension StudySubProblemsAnswerView {
    func configureUserAnswer(problem: Problem_Core) {
        self.terminated = false
        self.answersStackView.arrangedSubviews.forEach {
            self.answersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        self.subProblems.removeAll()
        
        guard let answer = problem.answer else { return }
        let answers = answer.components(separatedBy: "$").map { String($0) }
        
        for (idx, answer) in answers.enumerated() {
            let subProblemInputView = StudySubProblemInputView(name: Self.korLabels[idx], answer: answer)
            self.answersStackView.addArrangedSubview(subProblemInputView)
            self.subProblems.append(subProblemInputView)
        }
    }
    
    func configureDelegate(_ delegate: (AnswerCheckDelegate & UITextFieldDelegate)) {
        self.delegate = delegate
        self.subProblems.forEach { subProblem in
            subProblem.configureDelegate(delegate)
        }
    }
    
    func saveUserAnswer() {
        let userAnswer = self.subProblems.map { $0.textField.text ?? "" }.joined(separator: "$")
        self.delegate?.selectAnswer(to: userAnswer)
    }
    
    func terminate(problem: Problem_Core) {
        self.terminated = true
    }
}
