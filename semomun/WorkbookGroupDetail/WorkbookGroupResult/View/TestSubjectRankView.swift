//
//  TestSubjectRankView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class TestSubjectRankView: UIView {
    /* private */
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading4
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading1
        label.textColor = .getSemomunColor(.orangeRegular)
        return label
    }()
    
    init(title: String, rank: String) {
        super.init(frame: .zero)
        self.configureLayout()
        self.backgroundColor = .white
        self.titleLabel.text = title
        self.rankLabel.text = rank
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TestSubjectRankView {
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviews(self.titleLabel, self.rankLabel)
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 154),
            self.heightAnchor.constraint(equalToConstant: 59),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
            self.rankLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.rankLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
