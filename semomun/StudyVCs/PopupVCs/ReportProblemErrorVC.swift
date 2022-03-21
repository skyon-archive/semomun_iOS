//
//  ReportProblemErrorVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/10.
//

import UIKit

final class ReportProblemErrorVC: UIViewController {
    private var pageData: PageData
    private var buttons: [UIButton]
    private var checkboxes: [UIButton]
    private var selectedPid: Int?
    private var selectedCheckbox: Int?
    private var selectedText: String?
    private var errors: [String] = ["단순오탈자 혹은 한글 맞춤법 위배", "수식 오류"]
    private let xmarkImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(.xmark, withConfiguration: largeConfig)
    }()
    private let circleImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium, scale: .default)
        return UIImage(.circle, withConfiguration: largeConfig)
    }()
    private lazy var frameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    private lazy var errorTitleLabel: UILabel = {
        let label = self.leftLabel(title: "오류 내용")
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
        let leftLabel = self.leftLabel(title: "제목")
        view.addSubviews(leftLabel, self.titleLabel)
        NSLayoutConstraint.activate([
            leftLabel.widthAnchor.constraint(equalToConstant: 63),
            leftLabel.heightAnchor.constraint(equalToConstant: 23),
            leftLabel.topAnchor.constraint(equalTo: view.topAnchor),
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.titleLabel.widthAnchor.constraint(equalToConstant: 320),
            self.titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    private lazy var problemsFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let leftLabel = self.leftLabel(title: "문제 번호")
        view.addSubviews(leftLabel, self.problemsStackView)
        NSLayoutConstraint.activate([
            leftLabel.widthAnchor.constraint(equalToConstant: 63),
            leftLabel.heightAnchor.constraint(equalToConstant: 23),
            leftLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.problemsStackView.heightAnchor.constraint(equalToConstant: 38),
            self.problemsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.problemsStackView.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 12)
        ])
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 395)
        ])
        return view
    }()
    private lazy var userInputTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 3
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(.deepMint)?.cgColor
        textView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textView.textColor = .black
        textView.textAlignment = .left
        return textView
    }()
    private lazy var reportErrorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(.mainColor)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.setTitle("보내기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.prepareReport()
        }), for: .touchUpInside)
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pageData: PageData, title: String) {
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
    
    private func configureLayout() {
        self.view.addSubview(self.frameView)
        self.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.frameView.widthAnchor.constraint(equalToConstant: 572),
            self.frameView.heightAnchor.constraint(equalToConstant: 600),
            self.frameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.frameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.frameView.addSubviews(self.centerTitleLabel, self.closeButton, self.titleFrameView, self.problemsFrameView, self.errorTitleLabel, self.reportErrorButton)

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

        NSLayoutConstraint.activate([
            self.errorTitleLabel.leadingAnchor.constraint(equalTo: self.problemsFrameView.leadingAnchor),
            self.errorTitleLabel.topAnchor.constraint(equalTo: self.problemsFrameView.bottomAnchor, constant: 32)
        ])
        
        self.view.layoutIfNeeded()
        self.configureErrorTitles()
        self.configureUserError()
        
        NSLayoutConstraint.activate([
            self.reportErrorButton.widthAnchor.constraint(equalToConstant: 115),
            self.reportErrorButton.heightAnchor.constraint(equalToConstant: 43),
            self.reportErrorButton.centerXAnchor.constraint(equalTo: self.frameView.centerXAnchor),
            self.reportErrorButton.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor, constant: -67)
        ])
    }
    
    private func configureTitle(to title: String) {
        self.titleLabel.text = title
    }
    
    private func configureErrorTitles() {
        for (idx, error) in self.errors.enumerated() {
            let checkButton = self.checkboxButton(tag: idx)
            let errorLabel = self.errorLabel(title: error)
            self.frameView.addSubviews(checkButton, errorLabel)
            self.checkboxes.append(checkButton)
            
            if idx == 0 {
                checkButton.centerYAnchor.constraint(equalTo: self.errorTitleLabel.centerYAnchor).isActive = true
            } else {
                checkButton.topAnchor.constraint(equalTo: self.checkboxes[idx-1].bottomAnchor, constant: 14).isActive = true
            }
            
            NSLayoutConstraint.activate([
                checkButton.leadingAnchor.constraint(equalTo: self.errorTitleLabel.trailingAnchor, constant: 15),
                errorLabel.centerYAnchor.constraint(equalTo: self.checkboxes[idx].centerYAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: self.checkboxes[idx].trailingAnchor, constant: 13)
            ])
        }
    }
    
    private func configureUserError() {
        let userInputCheckButton = self.checkboxButton(tag: self.errors.count)
        let errorLabel = self.errorLabel(title: "기타")
        self.frameView.addSubviews(userInputCheckButton, errorLabel, self.userInputTextView)
        self.checkboxes.append(userInputCheckButton)
        
        NSLayoutConstraint.activate([
            userInputCheckButton.topAnchor.constraint(equalTo: self.checkboxes[self.errors.count-1].bottomAnchor, constant: 14),
            userInputCheckButton.leadingAnchor.constraint(equalTo: self.errorTitleLabel.trailingAnchor, constant: 15),
            errorLabel.centerYAnchor.constraint(equalTo: self.checkboxes[self.errors.count].centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: self.checkboxes[self.errors.count].trailingAnchor, constant: 13)
        ])
        
        NSLayoutConstraint.activate([
            self.userInputTextView.widthAnchor.constraint(equalToConstant: 222),
            self.userInputTextView.heightAnchor.constraint(equalToConstant: 120),
            self.userInputTextView.leadingAnchor.constraint(equalTo: errorLabel.trailingAnchor, constant: 12),
            self.userInputTextView.topAnchor.constraint(equalTo: errorLabel.topAnchor)
        ])
    }
    
    private func refreshButtons() {
        guard let selectedPid = self.selectedPid else { return }
        self.buttons.forEach { button in
            if button.tag == selectedPid {
                button.backgroundColor = UIColor(.deepMint)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    private func refreshCheckboxes() {
        guard let selectedCheckbox = selectedCheckbox else { return }
        print(selectedCheckbox)
        self.checkboxes.forEach { button in
            if button.tag == selectedCheckbox {
                button.backgroundColor = UIColor(.deepMint)
            } else {
                button.backgroundColor = .white
            }
        }
    }
    
    private func prepareReport() {
        guard let pid = self.selectedPid,
              let idx = self.selectedCheckbox else {
                  self.showErrorAlert()
                  return
              }
        let text: String
        if idx < self.errors.count {
            text = self.errors[idx]
        } else {
            guard let userText = self.userInputTextView.text,
                  userText != "" else  {
                self.showErrorAlert()
                return
            }
            text = userText
        }
        self.report(pid: pid, text: text)
    }
    
    private func showErrorAlert() {
        self.showAlertWithOK(title: "정보를 채워주세요", text: "문제번호와 오류내용을 기입해주세요")
    }
    
    private func report(pid: Int, text: String) {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        networkUsecase.postProblemError(pid: pid, text: text) { [weak self] status in
            switch status {
            case .SUCCESS:
                print("SUCCESS: post error")
            default:
                print("ERROR: post error")
            }
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension ReportProblemErrorVC {
    private func leftLabel(title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(.textColor)
        label.contentMode = .left
        label.text = title
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 63),
            label.heightAnchor.constraint(equalToConstant: 23),
        ])
        return label
    }
    
    private func problemButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.borderWidth = 1
        button.borderColor = UIColor(.deepMint)
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
    
    private func checkboxButton(tag: Int) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.circleImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.deepMint)?.cgColor
        button.layer.cornerRadius = 23/2
        button.tag = tag
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedCheckbox = tag
            self?.refreshCheckboxes()
        }), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 23),
            button.heightAnchor.constraint(equalToConstant: 23)
        ])
        return button
    }
    
    private func errorLabel(title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.contentMode = .left
        label.text = title
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 23)
        ])
        return label
    }
}
