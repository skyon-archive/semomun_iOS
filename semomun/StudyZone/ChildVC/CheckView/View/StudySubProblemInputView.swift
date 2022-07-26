//
//  StudySubProblemInputView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/26.
//

import UIKit

final class StudySubProblemInputView: UIView {
    /* public */
    private(set) var answer: String = ""
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = CGFloat.cornerRadius4
        textField.layer.cornerCurve = .continuous
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        textField.placeholder = "단답형"
        textField.font = UIFont.heading5
        textField.addLeftPadding(width: 8)
        textField.backgroundColor = UIColor.getSemomunColor(.white)
        
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 156),
            textField.heightAnchor.constraint(equalToConstant: 33)
        ])
        return textField
    }()
    /* private */
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 20),
            label.heightAnchor.constraint(equalToConstant: 33)
        ])
        return label
    }()
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.nameLabel, self.textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    private var answerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.smallStyleParagraph
        label.textColor = UIColor.systemRed
        label.textAlignment = .left
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 156),
            label.heightAnchor.constraint(equalToConstant: 22)
        ])
        return label
    }()
    private lazy var answerHorizontalStackView: UIStackView = {
        let leftSpaceView = UIView()
        leftSpaceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftSpaceView.widthAnchor.constraint(equalToConstant: 20),
            leftSpaceView.heightAnchor.constraint(equalToConstant: 22)
        ])
        let stackView = UIStackView(arrangedSubviews: [leftSpaceView, self.answerLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    convenience init(name: String, answer: String) {
        self.init(frame: CGRect())
        self.answer = answer
        self.nameLabel.text = name
        self.answerLabel.text = answer
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 0
        verticalStackView.addArrangedSubview(self.horizontalStackView)
        verticalStackView.addArrangedSubview(self.answerHorizontalStackView)
        self.answerHorizontalStackView.isHidden = true
        
        self.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension StudySubProblemInputView {
    func configureDelegate(_ delegate: UITextFieldDelegate) {
        self.textField.delegate = delegate
    }
    
    func terminateUI() -> Bool {
        let userAnswer = self.textField.text ?? ""
        if userAnswer == self.answer {
            self.nameLabel.textColor = UIColor.systemGreen
            self.textField.layer.borderColor = UIColor.systemGreen.cgColor
            return false
        } else {
            self.nameLabel.textColor = UIColor.systemRed
            self.textField.layer.borderColor = UIColor.systemRed.cgColor
            self.answerHorizontalStackView.isHidden = false
            return true
        }
    }
}
