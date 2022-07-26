//
//  StudySubProblemsAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/26.
//

import UIKit

final class StudySubProblemsAnswerView: UIView {
    /* public */
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
    private var answersStadkView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    private var terminated: Bool = false
    
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
        
        self.addSubview(self.answersStadkView)
        NSLayoutConstraint.activate([
            self.answersStadkView.topAnchor.constraint(equalTo: self.topBar.bottomAnchor, constant: 8),
            self.answersStadkView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.answersStadkView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.answersStadkView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}

extension StudySubProblemsAnswerView {
    func configureDelegate(_ delegate: (AnswerCheckDelegate & UITextFieldDelegate)) {
        self.delegate = delegate
        // textField 들의 delegate 연결이 필요
    }
    
    func configureUserAnswer(problem: Problem_Core) {
        self.terminated = false
    }
    
    func saveUserAnswer() {
        let answer = "1$2"
        // 각 view 들의 값들을 $처리 후 answer 로 변경하는 로직 필요
        self.delegate?.selectAnswer(to: answer)
    }
    
    func terminate(problem: Problem_Core) {
        self.terminated = true
    }
}
