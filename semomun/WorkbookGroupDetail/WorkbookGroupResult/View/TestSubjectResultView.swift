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
    private let cutoffStackView = TestCutoffStackView()
    
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
        self.percentageLabel.text = "\(testResult.percentile)%"
        self.standardScoreLabel.text = "\(testResult.standardScore)"
        self.cutoffStackView.configureContent(testResult.cutoff)
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
            
            self.percentageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            self.percentageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            self.standardScoreLabel.topAnchor.constraint(equalTo: self.percentageLabel.bottomAnchor, constant: 4),
            self.standardScoreLabel.leadingAnchor.constraint(equalTo: self.percentageLabel.leadingAnchor),
            
            self.percentageDescriptionLabel.trailingAnchor.constraint(equalTo: self.percentageLabel.leadingAnchor, constant: -12),
            self.percentageDescriptionLabel.centerYAnchor.constraint(equalTo: self.percentageLabel.centerYAnchor),
            
            self.standardScoreDescriptionLabel.trailingAnchor.constraint(equalTo: self.standardScoreLabel.leadingAnchor, constant: -12),
            self.standardScoreDescriptionLabel.centerYAnchor.constraint(equalTo: self.standardScoreLabel.centerYAnchor),
            
            self.cutoffStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.cutoffStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            self.cutoffStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.cutoffStackView.heightAnchor.constraint(equalToConstant: 315)
        ])
    }
}
