//
//  StudyShortTextAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class StudyShortTextAnswerView: UIView {
    static func size(terminated: Bool, isCorrect: Bool) -> CGSize {
        if terminated == false {
            return CGSize(172, 60)
        } else {
            return CGSize(172, isCorrect ? 60 : 78)
        }
    }
    private var topBar = StudyAnswerViewTopBar()
    private var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = CGFloat.cornerRadius4
        textField.layer.cornerCurve = .continuous
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 156),
            textField.heightAnchor.constraint(equalToConstant: 32)
        ])
        textField.placeholder = "서답형"
        textField.font = UIFont.heading5
        textField.textColor = UIColor.getSemomunColor(.black)
        textField.addLeftPadding(width: 8)
        textField.backgroundColor = UIColor.getSemomunColor(.white)
        return textField
    }()
    private var answerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.smallStyleParagraph
        label.textColor = UIColor.systemRed
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 14),
            label.widthAnchor.constraint(equalToConstant: 156)
        ])
        return label
    }()
    private var stackView: UIStackView = {
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
        
        self.stackView.addArrangedSubview(self.textField)
        self.stackView.addArrangedSubview(self.answerLabel)
        self.answerLabel.isHidden = true
        self.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topBar.bottomAnchor, constant: 8),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}

extension StudyShortTextAnswerView {
    func configureDelegate(delegate: UITextFieldDelegate) {
        self.textField.delegate = delegate
    }
    
    func configureUserAnsser(_ userAnswer: String?) {
        self.answerLabel.isHidden = true
        self.textField.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        self.textField.text = userAnswer ?? ""
    }
    
    func terminate(answer: String, userAnswer: String?) {
        if userAnswer == answer {
            self.textField.text = userAnswer
            self.textField.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            self.answerLabel.text = answer
            self.textField.text = userAnswer
            self.textField.layer.borderColor = UIColor.systemRed.cgColor
            self.answerLabel.isHidden = false
        }
    }
}
