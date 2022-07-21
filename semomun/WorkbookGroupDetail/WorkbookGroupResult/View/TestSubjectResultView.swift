//
//  TestSubjectResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class TestSubjectResultView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading3
        label.textColor = .getSemomunColor(.black)
        return label
    }()
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: UIFont.boldFont, size: 40)
        label.textColor = .getSemomunColor(.orangeRegular)
        label.text = "-"
        return label
    }()
    private let rankDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading4
        label.textColor = .getSemomunColor(.orangeRegular)
        label.text = "등급"
        return label
    }()
    private let percentageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        label.text = "예상 백분위"
        return label
    }()
    private let standardScoreDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        label.text = "예상 표준점수"
        return label
    }()
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let standardScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let cutoffStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.borderWidth = 1
        view.borderColor = .getSemomunColor(.border)
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.configureLayout()
        self.backgroundColor = .getSemomunColor(.white)
        self.layer.cornerRadius = .cornerRadius12
        self.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContent(_ testResult: PrivateTestResultOfDB) {
        self.titleLabel.text = testResult.subject
        self.rankLabel.text = testResult.rank
    }
}

extension TestSubjectResultView {
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.rankLabel, self.rankDescriptionLabel, self.percentageDescriptionLabel, self.standardScoreDescriptionLabel, self.percentageLabel, self.standardScoreLabel, self.cutoffStackView)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 447),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.rankLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            
            self.rankDescriptionLabel.bottomAnchor.constraint(equalTo: self.rankLabel.bottomAnchor, constant: -6),
            self.rankDescriptionLabel.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 4),
            
            self.percentageDescriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.percentageDescriptionLabel.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 123),
            
            self.standardScoreDescriptionLabel.trailingAnchor.constraint(equalTo: self.percentageDescriptionLabel.trailingAnchor),
            self.standardScoreDescriptionLabel.topAnchor.constraint(equalTo: self.percentageDescriptionLabel.bottomAnchor, constant: 4),
            
            self.percentageLabel.leadingAnchor.constraint(equalTo: self.percentageDescriptionLabel.trailingAnchor, constant: 12),
            self.percentageLabel.centerYAnchor.constraint(equalTo: self.percentageDescriptionLabel.centerYAnchor),
            
            self.standardScoreLabel.leadingAnchor.constraint(equalTo: self.standardScoreDescriptionLabel.trailingAnchor, constant: 12),
            self.standardScoreLabel.centerYAnchor.constraint(equalTo: self.standardScoreDescriptionLabel.centerYAnchor),
            
            self.cutoffStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.cutoffStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            self.cutoffStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.cutoffStackView.heightAnchor.constraint(equalToConstant: 315)
        ])
    }
}
