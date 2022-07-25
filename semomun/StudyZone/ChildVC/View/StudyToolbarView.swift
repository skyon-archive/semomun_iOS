//
//  StudyToolbarView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/25.
//

import UIKit

protocol StudyToolbarViewDelegate: AnyObject {
    func toggleBookmark()
    func toggleExplanation()
    func showAnswer()
}

final class StudyToolbarView: UIStackView {
    private let delegate: StudyToolbarViewDelegate
    
    private lazy var bookmarkImageView: UIButton = {
        let button = UIButton(type: .custom)
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
        button.setImageWithSVGTintColor(semomunImage: .bookmarkOutline, color: .lightGray)
        button.addAction(UIAction { [weak self] _ in self?.delegate.toggleBookmark() }, for: .touchUpInside)
        return button
    }()
    private lazy var explanationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.text = "해설"
        button.titleLabel?.font = .heading5
        button.titleLabel?.textColor = .getSemomunColor(.black)
        button.addAction(UIAction { [weak self] _ in self?.delegate.toggleExplanation() }, for: .touchUpInside)
        return button
    }()
    private lazy var answerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.text = "정답"
        button.titleLabel?.font = .heading5
        button.titleLabel?.textColor = .getSemomunColor(.black)
        button.addAction(UIAction { [weak self] _ in self?.delegate.showAnswer() }, for: .touchUpInside)
        return button
    }()
    
    init(delegate: StudyToolbarViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.spacing = 12
        self.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        self.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.backgroundColor = .getSemomunColor(.background)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        self.layer.cornerRadius = .cornerRadius12
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
        
        self.addArrangedSubview(self.bookmarkImageView)
        self.addArrangedSubview(self.answerButton)
        self.addArrangedSubview(self.answerButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
