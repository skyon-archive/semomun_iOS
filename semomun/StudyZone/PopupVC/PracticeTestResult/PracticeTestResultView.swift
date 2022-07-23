//
//  PracticeTestResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/22.
//

import UIKit

final class PracticeTestResultView: UIView {
    /* public */
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(.xOutline)
        button.setImageWithSVGTintColor(image: image, color: .lightGray)
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return button
    }()
    /* private */
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .getSemomunColor(.white)
        view.layer.cornerRadius = .cornerRadius24
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 523).isActive = true
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 691)
        heightConstraint.isActive = true
        heightConstraint.priority = .defaultLow
        return view
    }()
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading3
        label.textColor = .getSemomunColor(.black)
        label.text = "성적표"
        return label
    }()
    private let rawScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: UIFont.boldFont, size: 80)
        label.textColor = .getSemomunColor(.orangeRegular)
        label.heightAnchor.constraint(equalToConstant: 77).isActive = true
        return label
    }()
    private let infoStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        return view
    }()
    
    convenience init() {
        self.init(frame: .zero)
        self.configureLayout()
    }
    
    func configureContent(practiceTestResult: PracticeTestResult) {
        self.configureRawScoreLabel(practiceTestResult.privateScoreResult.rawScore)
        self.configureInfoStackView(practiceTestResult)
    }
}

extension PracticeTestResultView {
    private func configureLayout() {
        self.addSubviews(self.backgroundView)
        self.backgroundView.addSubview(self.scrollView)
        self.scrollView.addSubviews(self.titleLabel, self.closeButton, self.rawScoreLabel, self.infoStackView)
        
        NSLayoutConstraint.activate([
            self.backgroundView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundView.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            self.backgroundView.topAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            self.scrollView.topAnchor.constraint(equalTo: self.backgroundView.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.widthAnchor),
            self.scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.backgroundView.widthAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            
            self.closeButton.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 24),
            self.closeButton.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            
            self.rawScoreLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.rawScoreLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            
            self.infoStackView.leadingAnchor.constraint(equalTo: self.rawScoreLabel.trailingAnchor, constant: 24),
            self.infoStackView.bottomAnchor.constraint(equalTo: self.rawScoreLabel.bottomAnchor)
        ])
    }
    
    private func configureRawScoreLabel(_ rawScore: Int) {
        let rawScoreText = NSMutableAttributedString(string: "\(rawScore)점")
        rawScoreText.setAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: UIFont.boldFont, size: 80) ?? .systemFont(ofSize: 80, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.orangeRegular)
            ],
            range: NSMakeRange(0, rawScoreText.length-1)
        )
        rawScoreText.setAttributes(
            [
                NSAttributedString.Key.font: UIFont.heading3 ,
                NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.orangeRegular)
            ],
            range: NSMakeRange(rawScoreText.length-1, 1)
        )
        self.rawScoreLabel.attributedText = rawScoreText
    }
    
    private func configureInfoStackView(_ practiceTestResult: PracticeTestResult) {
        [
            ["맞은 개수", "\(practiceTestResult.correctProblemCount)/\(practiceTestResult.totalProblemCount)"],
            ["풀이 시간", "\(practiceTestResult.totalTimeFormattedString)"]
        ].forEach { data in
            let horizontalStackView = UIStackView()
            horizontalStackView.spacing = 4
            
            let title = UILabel()
            title.font = .regularStyleParagraph
            title.textColor = .getSemomunColor(.lightGray)
            title.textAlignment = .left
            title.text = data[0]
            horizontalStackView.addArrangedSubview(title)
            
            let description = UILabel()
            description.font = .regularStyleParagraph
            description.textColor = .getSemomunColor(.darkGray)
            description.textAlignment = .right
            description.text = data[1]
            horizontalStackView.addArrangedSubview(description)
            
            self.infoStackView.addArrangedSubview(horizontalStackView)
        }
        
    }
}
