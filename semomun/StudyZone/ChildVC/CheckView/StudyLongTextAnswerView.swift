//
//  StudyLongTextAnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class StudyLongTextAnswerView: UIView {
    static let size = CGSize(240, 78)
    private var topBar = StudyAnswerViewTopBar()
    private let textViewPlaceHolder = "서술형\n(두 줄)"
    private lazy var textView: UITextView = {
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
        textView.textColor = UIColor.getSemomunColor(.lightGray)
        textView.backgroundColor = UIColor.getSemomunColor(.white)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.text = self.textViewPlaceHolder
        return textView
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
    
    func configureUserAnsser(_ userAnswer: String?) {
        if let userAnswer = userAnswer {
            self.textView.textColor = UIColor.getSemomunColor(.black)
            self.textView.text = userAnswer
        } else {
            self.textView.textColor = UIColor.getSemomunColor(.lightGray)
            self.textView.text = self.textViewPlaceHolder
        }
    }
}
