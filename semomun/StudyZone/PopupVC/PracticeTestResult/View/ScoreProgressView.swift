//
//  ScoreProgressView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/23.
//

import UIKit

class ScoreProgressView: UIStackView {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regularStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        label.widthAnchor.constraint(equalToConstant: 92).isActive = true
        label.numberOfLines = 0
        return label
    }()
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.backgroundColor = .getSemomunColor(.background)
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        view.widthAnchor.constraint(equalToConstant: 350).isActive = true
        return view
    }()
    private let progressForegroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        return view
    }()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.textColor = .getSemomunColor(.lightGray)
        label.widthAnchor.constraint(equalToConstant: 20).isActive = true
        label.text = "- "
        return label
    }()
    private let progressBarWidth: CGFloat = 350
    private lazy var progressWidthConstraint: NSLayoutConstraint = {
        return self.progressForegroundView.widthAnchor.constraint(equalToConstant: 0)
    }()
    
    convenience init(description: String, color: UIColor) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 34).isActive = true
        self.spacing = 8
        self.alignment = .center
        self.addArrangedSubview(self.descriptionLabel)
        self.addArrangedSubview(self.progressBackgroundView)
        self.addArrangedSubview(self.progressLabel)
        self.descriptionLabel.text = description
        self.progressForegroundView.backgroundColor = color
        self.configureProgressForegroundViewLayout()
    }
    
    func updateProgress(rawScore: Int, perfectScore: Int) {
        self.progressWidthConstraint.constant = self.progressBarWidth * min(1, CGFloat(rawScore) / CGFloat(perfectScore))
        self.progressLabel.text = "\(rawScore)"
    }
}

extension ScoreProgressView {
    private func configureProgressForegroundViewLayout() {
        self.progressBackgroundView.addSubview(self.progressForegroundView)
        NSLayoutConstraint.activate([
            self.progressForegroundView.centerYAnchor.constraint(equalTo: self.progressBackgroundView.centerYAnchor),
            self.progressForegroundView.leadingAnchor.constraint(equalTo: self.progressBackgroundView.leadingAnchor),
            self.progressWidthConstraint
        ])
    }
}
