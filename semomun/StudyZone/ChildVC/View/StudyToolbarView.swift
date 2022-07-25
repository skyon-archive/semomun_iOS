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
}

final class StudyToolbarView: UIStackView {
    /* public */
    static let height: CGFloat = 36
    var bookmarkSelected: Bool {
        return self.bookmarkButton.isSelected
    }
    /* private */
    private weak var delegate: StudyToolbarViewDelegate?
    private let answerView = AnswerView()
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.background)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        view.layer.cornerRadius = .cornerRadius12
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
        button.setImageWithSVGTintColor(semomunImage: .bookmarkOutline, color: .lightGray)
        button.addAction(UIAction { [weak self] _ in
            button.isSelected.toggle()
            button.tintColor = button.isSelected ? .getSemomunColor(.blueRegular) : .getSemomunColor(.lightGray)
            self?.delegate?.toggleBookmark()
        }, for: .touchUpInside)
        return button
    }()
    private lazy var explanationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("해설", for: .normal)
        button.setTitleColor(.getSemomunColor(.black), for: .normal)
        button.titleLabel?.font = .heading5
        button.addAction(UIAction { [weak self] _ in self?.delegate?.toggleExplanation() }, for: .touchUpInside)
        return button
    }()
    private lazy var answerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("정답", for: .normal)
        button.setTitleColor(.getSemomunColor(.black), for: .normal)
        button.titleLabel?.font = .heading5
        button.addAction(UIAction { [weak self] _ in self?.showAnswer() }, for: .touchUpInside)
        return button
    }()
    private var answer: String?
    
    /// FormZero에서는 init으로 delegate를 전달
    init(delegate: StudyToolbarViewDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.spacing = 12
        self.directionalLayoutMargins = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        self.isLayoutMarginsRelativeArrangement = true
        self.heightAnchor.constraint(equalToConstant: Self.height).isActive = true
        
        self.addSubview(self.backgroundView)
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.addArrangedSubview(self.bookmarkButton)
        self.addArrangedSubview(self.answerButton)
        self.addArrangedSubview(self.explanationButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(mode: StudyVC.Mode, problem: Problem_Core?, answer: String?) {
        if let answer = answer, problem?.terminated == false {
            self.answerView.configureAnswer(to: answer)
            self.answerButton.isHidden = false
            self.answerButton.isUserInteractionEnabled = true
            self.answerButton.setTitleColor(.getSemomunColor(.black), for: .normal)
        } else {
            self.answerButton.isHidden = true
        }

        self.bookmarkButton.isSelected = problem?.star ?? false
        self.bookmarkButton.tintColor = self.bookmarkButton.isSelected ? .getSemomunColor(.blueRegular) : .getSemomunColor(.lightGray)
        
        
        self.explanationButton.isSelected = false
        if problem?.explanationImage != nil {
            self.explanationButton.isUserInteractionEnabled = true
            self.explanationButton.setTitleColor(.getSemomunColor(.black), for: .normal)
        } else {
            self.explanationButton.isHidden = true
        }
        
        if mode == .practiceTest && (problem?.terminated == false) {
            self.explanationButton.isHidden = true
            self.answerButton.isHidden = true
        }
    }
    
    /// FormOne에서는 configure로 Delegate 전달
    func configureDelegate(_ delegate: StudyToolbarViewDelegate) {
        self.delegate = delegate
    }
    
    func hideAnswerView() {
        self.answerView.removeFromSuperview()
    }
}

extension StudyToolbarView {
    private func showAnswer() {
        self.addSubview(self.answerView)
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerButton.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerButton.centerXAnchor)
        ])
        self.answerView.showShortTime()
    }
}
