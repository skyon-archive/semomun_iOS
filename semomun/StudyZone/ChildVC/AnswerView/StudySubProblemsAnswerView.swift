//
//  StudySubProblemsAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/26.
//

import UIKit

typealias SubproblemsAnswerViewDelegate = (AnswerViewDelegate & UITextFieldDelegate)

final class StudySubProblemsAnswerView: UIView {
    /* public */
    static let korLabels = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ"]
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
    static func wrongCount(problem: Problem_Core) -> Int {
        let problemCount = problem.subProblemsCount
        var answers: [String] = []
        if let answer = problem.answer {
            answers = answer.components(separatedBy: "$").map { String($0) }
        } else {
            answers = Array(repeating: "", count: Int(problemCount))
        }
        var userAnswers: [String] = []
        if let userAnswer = problem.solved {
            userAnswers = userAnswer.components(separatedBy: "$").map { String($0) }
        } else {
            userAnswers = Array(repeating: "", count: Int(problemCount))
        }
        
        return zip(userAnswers, answers).filter { $0 != $1 }.count
    }
    /* prvate */
    private weak var delegate: SubproblemsAnswerViewDelegate?
    private var topBar = StudyAnswerViewTopBar()
    private var answersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    private var subProblems: [StudySubProblemInputView] = []
    private var currentTextFieldIndex: Int = 0
    
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
    func configureDelegate(delegate: SubproblemsAnswerViewDelegate) {
        self.delegate = delegate
    }
    
    func configureUserAnswer(problem: Problem_Core) {
        self.answersStackView.arrangedSubviews.forEach {
            self.answersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        self.subProblems.removeAll()
        
        guard let delegate = self.delegate else { return }
        guard let answer = problem.answer else { return }
        let count = Int(problem.subProblemsCount)
        let answers = answer.components(separatedBy: "$").map { String($0) }
        let userAnswers = self.userAnswers(coreUserAnswers: problem.solved, answerCount: count)
        
        for idx in 0..<count {
            let subProblemInputView = StudySubProblemInputView(name: Self.korLabels[idx], answer: answers[safe: idx] ?? "", userAnswer: userAnswers[safe: idx] ?? "", tag: idx)
            subProblemInputView.configureDelegate(delegate)
            subProblemInputView.textField.addTarget(self, action: #selector(updateAnswer(_:)), for: .editingChanged)
            self.answersStackView.addArrangedSubview(subProblemInputView)
            self.subProblems.append(subProblemInputView)
        }
    }
    
    func saveUserAnswer() {
        let userAnswer = self.subProblems.map { $0.textField.text ?? "" }.joined(separator: "$")
        self.delegate?.selectAnswer(to: userAnswer)
    }
    
    func terminate() {
        self.subProblems.forEach { $0.terminateUI() }
    }
    
    @objc private func updateAnswer(_ textField: UITextField) {
        self.currentTextFieldIndex = textField.tag
        self.saveUserAnswer()
    }
    
    func changeToNextTextField() {
        if currentTextFieldIndex == self.subProblems.count-1 {
            self.subProblems[self.currentTextFieldIndex].textField.resignFirstResponder()
        } else {
            self.currentTextFieldIndex = min(self.subProblems.count-1, self.currentTextFieldIndex+1)
            self.subProblems[self.currentTextFieldIndex].textField.becomeFirstResponder()
        }
    }
}

extension StudySubProblemsAnswerView {
    private func userAnswers(coreUserAnswers: String?, answerCount: Int) -> [String] {
        if let userAnswers = coreUserAnswers {
            return userAnswers.components(separatedBy: "$").map { String($0) }
        } else {
            return Array(repeating: "", count: answerCount)
        }
    }
}
