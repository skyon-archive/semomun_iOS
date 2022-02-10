//
//  ReportProblemErrorView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/09.
//

import UIKit

protocol ReportRemover: AnyObject {
    func closeReportView()
    func reportError(pid: Int, text: String)
}

final class ReportProblemErrorView: UIView {
    private weak var delegate: ReportRemover?
    private var pageData: PageData
    private var buttons: [UIButton]
    private var checkboxes: [UIButton]
    private var selectedPid: Int?
    
    private let xmarkImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(systemName: SemomunImage.xmark, withConfiguration: largeConfig)
    }()
    private lazy var centerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.contentMode = .center
        label.text = "오류신고"
        return label
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.xmarkImage, for: .normal)
        button.tintColor = .black
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.closeReportView()
        }), for: .touchUpInside)
        return button
    }()
    private lazy var leftTitle1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(.textColor)
        label.contentMode = .left
        label.text = "제목"
        return label
    }()
    private lazy var leftTitle2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(.textColor)
        label.contentMode = .left
        label.text = "문제 번호"
        return label
    }()
    private lazy var leftTitle3: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(.textColor)
        label.contentMode = .left
        label.text = "오류 내용"
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.contentMode = .left
        return label
    }()
    private lazy var titleFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(self.leftTitle1, self.titleLabel)
        NSLayoutConstraint.activate([
            self.leftTitle1.widthAnchor.constraint(equalToConstant: 63),
            self.leftTitle1.heightAnchor.constraint(equalToConstant: 23),
            self.leftTitle1.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.leftTitle1.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.titleLabel.widthAnchor.constraint(equalToConstant: 320),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 23),
            self.titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leftTitle1.trailingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    private lazy var problemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 17
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pageData: PageData) {
        self.pageData = pageData
        self.buttons = []
        self.checkboxes = []
        super.init(frame: CGRect())
        self.configureStackView()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.addSubviews(self.centerTitleLabel, self.closeButton)
    }
    
    private func configureStackView() {
        self.pageData.problems.forEach { problem in
            let button = self.problemButton()
            button.setTitle(problem.pName, for: .normal)
            button.tag = Int(problem.pid)
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.selectedPid = Int(problem.pid)
                self?.refreshButtons()
            }), for: .touchUpInside)
            self.buttons.append(button)
            self.problemsStackView.addArrangedSubview(button)
        }
    }
    
    private func problemButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.borderWidth = 1
        button.borderColor = UIColor(.mainColor)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .white
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 38),
            button.heightAnchor.constraint(equalToConstant: 38)
        ])
        return button
    }
    
    private func refreshButtons() {
        guard let selectedPid = self.selectedPid else { return }
        self.buttons.forEach { button in
            if button.tag == selectedPid {
                button.backgroundColor = UIColor(.mainColor)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
}

