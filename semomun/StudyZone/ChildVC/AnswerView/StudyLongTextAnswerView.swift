//
//  StudyLongTextAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class StudyLongTextAnswerView: UIView {
    /* public */
    static let size = CGSize(240, 78)
    static let placeholderTextColor = UIColor.getSemomunColor(.lightGray)
    static let placeHolder = "서술형\n(두 줄)"
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = CGFloat.cornerRadius4
        textView.layer.cornerCurve = .continuous
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: 224),
            textView.heightAnchor.constraint(equalToConstant: 50)
        ])
        textView.font = UIFont.heading5
        textView.backgroundColor = UIColor.getSemomunColor(.white)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textColor = Self.placeholderTextColor
        textView.text = Self.placeHolder
        return textView
    }()
    /* private */
    private var topBar = StudyAnswerViewTopBar()
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
        
        self.addSubview(self.textView)
        NSLayoutConstraint.activate([
            self.textView.topAnchor.constraint(equalTo: self.topBar.bottomAnchor, constant: 8),
            self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}

extension StudyLongTextAnswerView {
    func configureDelegate(delegate: UITextViewDelegate) {
        self.textView.delegate = delegate
    }
    
    func configureUserAnswer(_ userAnswer: String?) {
        self.textView.isUserInteractionEnabled = true
        if let userAnswer = userAnswer, userAnswer != "" {
            self.textView.textColor = UIColor.getSemomunColor(.black)
            self.textView.text = userAnswer
        } else {
            self.textView.textColor = Self.placeholderTextColor
            self.textView.text = Self.placeHolder
        }
    }
    
    func terminate() {
        self.textView.isUserInteractionEnabled = false
    }
}
