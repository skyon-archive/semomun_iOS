//
//  Study5AnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class Study5AnswerView: UIView {
    static let size = CGSize(172, 56)
    private weak var delegate: AnswerCheckDelegate?
    private var topBar = StudyAnswerViewTopBar()
    private var answersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    private var terminated: Bool = false
    private var shouldMultipleAnswer: Bool = false
    
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
        self.configureButtons()
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
    
    private func configureButtons() {
        [("1", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5)].forEach { answer, tag in
            let button = StudyCircleAnswerButton(answer: answer, tag: tag)
            self.answersStackView.addArrangedSubview(button)
            button.addAction(UIAction(handler: { [weak self] _ in
                guard self?.terminated == false else { return }
                self?.delegate?.selectAnswer(to: answer)
                self?.updateButtonsUI(selectedTag: tag)
            }), for: .touchUpInside)
            
        }
    }
    
    private func updateButtonsUI(selectedTag: Int) {
        let buttons = self.answersStackView.arrangedSubviews.compactMap { $0 as? StudyCircleAnswerButton }
        if self.shouldMultipleAnswer == true {
            buttons[selectedTag-1].isSelected.toggle()
        } else {
            buttons.forEach { button in
                button.isSelected = button.tag == selectedTag
            }
        }
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

extension Study5AnswerView {
    func configureDelegate(delegate: AnswerCheckDelegate) {
        self.delegate = delegate
    }
    
    func configureUserAnswer(_ userAnswer: [String], _ terminated: Bool, shouldMultipleAnswer: Bool) {
        self.terminated = terminated
        let buttons = self.answersStackView.arrangedSubviews.compactMap { $0 as? StudyCircleAnswerButton }
        self.shouldMultipleAnswer = shouldMultipleAnswer
        if shouldMultipleAnswer == true { // 여러 문제 select
            buttons.forEach { button in
                button.isSelected = userAnswer.contains(button.answer)
            }
        } else { // 한문제 select
            guard let userAnswer = userAnswer.first else {
                buttons.forEach { $0.isSelected = false }
                return
            }
            
            buttons.forEach { button in
                button.isSelected = button.answer == userAnswer
            }
        }
    }
    
    func terminate(answer: [String], userAnswer: [String]) {
        self.terminated = true
        let buttons = self.answersStackView.arrangedSubviews.compactMap { $0 as? StudyCircleAnswerButton }
        buttons.forEach { button in
            if answer.contains(button.answer) {
                button.terminatedAnswerUI(isSelected: userAnswer.contains(button.answer))
            } else {
                button.terminatedNotAnswerUI(isSelected: userAnswer.contains(button.answer))
            }
        }
    }
}
