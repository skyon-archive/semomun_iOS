//
//  ProblemTextResultView.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/23.
//

import UIKit

final class ProblemTextResultView: UIView {
    private lazy var solvedAnswerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.contentMode = .left
        return label
    }()
    private lazy var answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.contentMode = .left
        return label
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.addSubviews(self.solvedAnswerLabel, self.answerLabel)
        self.backgroundColor = .white
        self.borderWidth = 1
        self.borderColor = UIColor(.deepMint)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            self.solvedAnswerLabel.heightAnchor.constraint(equalToConstant: 20),
            self.solvedAnswerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.solvedAnswerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            self.answerLabel.heightAnchor.constraint(equalToConstant: 20),
            self.answerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.answerLabel.leadingAnchor.constraint(equalTo: self.solvedAnswerLabel.trailingAnchor, constant: 20),
            self.answerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func configureSolvedAnswer(to answer: String) {
        self.solvedAnswerLabel.text = "나의 답안: \(answer)"
    }
    
    func configureAnswer(to answer: String) {
        self.answerLabel.text = "정답: \(answer)"
    }
}
