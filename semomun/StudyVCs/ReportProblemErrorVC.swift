//
//  ReportProblemErrorVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/10.
//

import UIKit

protocol ReportRemover: AnyObject {
    func reportError(pid: Int, text: String)
}

final class ReportProblemErrorVC: UIViewController {
    private weak var delegate: ReportRemover?
    private var pageData: PageData
    private var buttons: [UIButton]
    private var checkboxes: [UIButton]
    private var selectedPid: Int?
    
    private let xmarkImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(systemName: SemomunImage.xmark, withConfiguration: largeConfig)
    }()
    private lazy var frameView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
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
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
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
    private lazy var problemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 17
        return stackView
    }()
    private lazy var titleFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(self.leftTitle1, self.titleLabel)
        NSLayoutConstraint.activate([
            self.leftTitle1.widthAnchor.constraint(equalToConstant: 63),
            self.leftTitle1.heightAnchor.constraint(equalToConstant: 23),
            self.leftTitle1.topAnchor.constraint(equalTo: view.topAnchor),
            self.leftTitle1.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.titleLabel.widthAnchor.constraint(equalToConstant: 320),
            self.titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leftTitle1.trailingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    private lazy var problemsFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(self.leftTitle2, self.problemsStackView)
        NSLayoutConstraint.activate([
            self.leftTitle2.widthAnchor.constraint(equalToConstant: 63),
            self.leftTitle2.heightAnchor.constraint(equalToConstant: 23),
            self.leftTitle2.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.leftTitle2.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.problemsStackView.heightAnchor.constraint(equalToConstant: 38),
            self.problemsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.problemsStackView.leadingAnchor.constraint(equalTo: self.leftTitle2.trailingAnchor, constant: 12)
        ])
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 63+12+320)
        ])
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(delegate: ReportRemover, pageData: PageData, title: String) {
        self.delegate = delegate
        self.pageData = pageData
        self.buttons = []
        self.checkboxes = []
        super.init(nibName: nil, bundle: nil)
        
        self.configureTitle(to: title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackView()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.frameView, self.centerTitleLabel, self.closeButton, self.titleFrameView, self.problemsFrameView)
        self.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.frameView.widthAnchor.constraint(equalToConstant: 572),
            self.frameView.heightAnchor.constraint(equalToConstant: 600),
            self.frameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.frameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.centerTitleLabel.centerXAnchor.constraint(equalTo: self.frameView.centerXAnchor),
            self.centerTitleLabel.topAnchor.constraint(equalTo: self.frameView.topAnchor, constant: 50)
        ])
        
        NSLayoutConstraint.activate([
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.topAnchor.constraint(equalTo: self.frameView.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            self.titleFrameView.centerXAnchor.constraint(equalTo: self.frameView.centerXAnchor),
            self.titleFrameView.topAnchor.constraint(equalTo: self.centerTitleLabel.bottomAnchor, constant: 40)
        ])
        
        NSLayoutConstraint.activate([
            self.problemsFrameView.heightAnchor.constraint(equalToConstant: 38),
            self.problemsFrameView.centerXAnchor.constraint(equalTo: self.frameView.centerXAnchor),
            self.problemsFrameView.topAnchor.constraint(equalTo: self.titleFrameView.bottomAnchor, constant: 24)
        ])
    }
    
    private func configureTitle(to title: String) {
        self.titleLabel.text = title
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
