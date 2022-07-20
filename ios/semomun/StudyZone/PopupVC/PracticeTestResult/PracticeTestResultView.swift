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
    private let progressViews = [
        ScoreProgressView(description: "나의 점수", color: .getSemomunColor(.orangeRegular)),
        ScoreProgressView(description: "평균 점수", color: UIColor(hex: 0xDCDCE5)),
        ScoreProgressView(description: "세모문 사용자의 평균점수", color: UIColor(hex: 0xDCDCE5))
    ]
    private let progressStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .getSemomunColor(.border)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    private let privateScoreResultView = ScoreResultView(title: "나의 예상 등급", rankLabelColor: .getSemomunColor(.orangeRegular))
    private let publicScoreResultView = ScoreResultView(title: "세모문 사용자 중 예상 등급", rankLabelColor: .getSemomunColor(.blueRegular))
    private let cutoffDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let cutoffStackView = TestCutoffStackView()
    
    convenience init() {
        self.init(frame: .zero)
        self.configureLayout()
        self.progressViews.forEach {
            self.progressStackView.addArrangedSubview($0)
        }
    }
}

// MARK: Configure
extension PracticeTestResultView {
    func configureLocalContent(practiceTestResult: PracticeTestResult) {
        self.configureRawScoreLabel(practiceTestResult.rawScore)
        self.configureInfoStackView(practiceTestResult)
        self.configureProgressStackView(practiceTestResult)
        
        self.privateScoreResultView.configureContent(
            rank: practiceTestResult.rank,
            standardScore: practiceTestResult.standardScore,
            percentile: practiceTestResult.percentile
        )
        
        self.cutoffDescriptionLabel.text = practiceTestResult.subject
        self.cutoffStackView.configureContent(
            cutoffs: practiceTestResult.cutoff,
            userRank: practiceTestResult.rank
        )
    }
}

// MARK: Update
extension PracticeTestResultView {
    func updateServerContent(publicTestResult: PublicTestResultOfDB, perfectScore: Int) {
        self.progressViews[2].updateProgress(rawScore: publicTestResult.rawScore, perfectScore: perfectScore)
        self.publicScoreResultView.configureContent(
            rank: publicTestResult.rank,
            standardScore: publicTestResult.standardScore,
            percentile: publicTestResult.percentile
        )
    }
    
    func updateNoInternetUI() {
        self.progressViews[2].removeProgess()
        self.publicScoreResultView.configureNoInternetUI()
    }
}

extension PracticeTestResultView {
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
            horizontalStackView.distribution = .fillEqually
            
            let title = UILabel()
            title.font = .regularStyleParagraph
            title.textColor = .getSemomunColor(.lightGray)
            title.text = data[0]
            horizontalStackView.addArrangedSubview(title)
            
            let description = UILabel()
            description.font = .regularStyleParagraph
            description.textColor = .getSemomunColor(.darkGray)
            description.textAlignment = .left
            description.text = data[1]
            horizontalStackView.addArrangedSubview(description)
            
            self.infoStackView.addArrangedSubview(horizontalStackView)
        }
    }
    
    private func configureProgressStackView(_ practiceTestResult: PracticeTestResult) {
        self.progressViews[0].updateProgress(
            rawScore: practiceTestResult.rawScore,
            perfectScore: practiceTestResult.perfectScore
        )
        self.progressViews[1].updateProgress(
            rawScore: practiceTestResult.groupAverage,
            perfectScore: practiceTestResult.perfectScore
        )
    }
}

// MARK: Layout
extension PracticeTestResultView {
    private func configureLayout() {
        self.addSubviews(self.backgroundView)
        self.backgroundView.addSubview(self.scrollView)
        self.scrollView.addSubviews(self.titleLabel, self.closeButton, self.rawScoreLabel, self.infoStackView, self.progressStackView, self.borderView, self.privateScoreResultView, self.publicScoreResultView, self.cutoffDescriptionLabel, self.cutoffStackView)
        
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
            self.infoStackView.bottomAnchor.constraint(equalTo: self.rawScoreLabel.bottomAnchor),
            
            self.progressStackView.topAnchor.constraint(equalTo: self.rawScoreLabel.bottomAnchor, constant: 24),
            self.progressStackView.leadingAnchor.constraint(equalTo: self.rawScoreLabel.leadingAnchor),
            
            self.borderView.topAnchor.constraint(equalTo: self.progressStackView.bottomAnchor, constant: 24),
            self.borderView.widthAnchor.constraint(equalTo: self.progressStackView.widthAnchor),
            self.borderView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.privateScoreResultView.topAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: 24),
            self.privateScoreResultView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor),
            
            self.publicScoreResultView.topAnchor.constraint(equalTo: self.privateScoreResultView.bottomAnchor, constant: 57),
            self.publicScoreResultView.leadingAnchor.constraint(equalTo: self.privateScoreResultView.leadingAnchor),
            
            self.cutoffDescriptionLabel.topAnchor.constraint(equalTo: self.privateScoreResultView.topAnchor),
            self.cutoffDescriptionLabel.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.centerXAnchor, constant: 6),
            
            self.cutoffStackView.topAnchor.constraint(equalTo: self.cutoffDescriptionLabel.bottomAnchor, constant: 16),
            self.cutoffStackView.leadingAnchor.constraint(equalTo: self.cutoffDescriptionLabel.leadingAnchor),
            self.cutoffStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            self.cutoffStackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            self.cutoffStackView.heightAnchor.constraint(equalToConstant: 315)
        ])
    }
}
