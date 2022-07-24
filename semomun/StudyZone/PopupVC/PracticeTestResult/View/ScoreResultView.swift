//
//  ScoreResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/24.
//

import UIKit

final class ScoreResultView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .heading5
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: UIFont.boldFont, size: 50)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        label.heightAnchor.constraint(equalToConstant: 84).isActive = true
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        label.layer.cornerRadius = .cornerRadius12
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        return label
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 8
        return view
    }()
    
    convenience init(title: String, rankLabelColor: UIColor) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureLayout()
        self.titleLabel.text = title
        self.rankLabel.textColor = rankLabelColor
    }
    
    func configureContent(_ scoreResult: ScoreResult) {
        self.rankLabel.text = scoreResult.rank
        
        [
            ["예상 표준점수", "\(scoreResult.standardScore)"],
            ["예상 백분위", "\(scoreResult.percentile)%"]
        ].forEach { data in
            let groupStackView = UIStackView()
            groupStackView.axis = .vertical
            groupStackView.spacing = 4
            groupStackView.alignment = .leading
            
            let descriptionLabel = UILabel()
            descriptionLabel.font = .regularStyleParagraph
            descriptionLabel.textColor = .getSemomunColor(.lightGray)
            descriptionLabel.text = data[0]
            groupStackView.addArrangedSubview(descriptionLabel)
            
            let dataLabel = UILabel()
            dataLabel.font = .regularStyleParagraph
            dataLabel.textColor = .getSemomunColor(.darkGray)
            dataLabel.text = data[1]
            groupStackView.addArrangedSubview(dataLabel)
            
            self.stackView.addArrangedSubview(groupStackView)
        }
    }
}

extension ScoreResultView {
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.rankLabel, self.stackView)
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.rankLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.rankLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.stackView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 16)
        ])
    }
}
