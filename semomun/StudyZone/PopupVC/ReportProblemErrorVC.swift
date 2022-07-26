//
//  ReportProblemErrorVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/10.
//

import UIKit

final class ReportProblemErrorVC: UIViewController {
    private enum ErrorType: CaseIterable, CustomStringConvertible {
        case typo
        case expressionError
        case others
        var description: String {
            switch self {
            case .typo:
                return "단순 오탈자 혹은 한글 맞춤법 위배"
            case .expressionError:
                return "수식 오류"
            case .others:
                return "기타"
            }
        }
    }
    
    private var selectedPid: Int? {
        didSet {
            self.updateReportErrorButtonStatus()
        }
    }
    private var selectedErrorType = ErrorType.typo {
        didSet {
            switch selectedErrorType {
            case .typo:
                self.textView.isHidden = true
            case .expressionError:
                self.textView.isHidden = true
            case .others:
                self.textView.isHidden = false
            }
            self.updateReportErrorButtonStatus()
        }
    }
    private var selectProblemButtons: [SelectProblemButton] = []
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.white)
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 472).isActive = true
        view.heightAnchor.constraint(equalToConstant: 501).isActive = true
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading3
        label.textColor = .getSemomunColor(.black)
        label.text = "오류 신고"
        return label
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(.xOutline)
        button.setImageWithSVGTintColor(image: image, color: .lightGray)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }), for: .touchUpInside)
        return button
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 24
        return view
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        textView.layer.cornerRadius = 8
        textView.layer.cornerCurve = .continuous
        textView.layer.masksToBounds = true
        textView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        textView.isHidden = true
        textView.text = "오류에 대해 입력해주세요"
        textView.textColor = self.placeholderTextColor
        
        return textView
    }()
    private lazy var reportErrorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .getSemomunColor(.lightGray)
        button.isUserInteractionEnabled = false
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = .cornerRadius12
        button.heightAnchor.constraint(equalToConstant: 43).isActive = true
        
        button.setTitle("신고", for: .normal)
        button.titleLabel?.font = .heading4
        button.setTitleColor(.getSemomunColor(.white), for: .normal)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.report()
        }), for: .touchUpInside)
        return button
    }()
    private let placeholderTextColor = UIColor.getSemomunColor(.lightGray)
    
    convenience init(pageData: PageData, workbookTitle: String, sectionNum: Int, sectionTitle: String) {
        self.init(nibName: nil, bundle: nil)
        self.configureLayout()
        self.configureProblemInfoView(workbookTitle: workbookTitle, sectionNum: sectionNum, sectionTitle: sectionTitle)
        self.configureProblemStackView(problems: pageData.problems)
        self.configureCategory()
    }
    
    private func configureProblemInfoView(workbookTitle: String, sectionNum: Int, sectionTitle: String) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let workbookTitleLabel = UILabel()
        workbookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        workbookTitleLabel.font = .heading4
        workbookTitleLabel.textColor = .getSemomunColor(.black)
        workbookTitleLabel.text = workbookTitle
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .getSemomunColor(.border)
        
        let sectionNumLabel = UILabel()
        sectionNumLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionNumLabel.font = .heading4
        sectionNumLabel.textColor = .getSemomunColor(.black)
        sectionNumLabel.text =  String(format: "%02d", sectionNum)
        
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.font = .largeStyleParagraph
        sectionTitleLabel.textColor = .getSemomunColor(.darkGray)
        sectionTitleLabel.text = sectionTitle
        view.addSubviews(workbookTitleLabel, border, sectionNumLabel, sectionTitleLabel)
        
        NSLayoutConstraint.activate([
            workbookTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            workbookTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            border.heightAnchor.constraint(equalToConstant: 1),
            border.widthAnchor.constraint(equalTo: view.widthAnchor),
            border.topAnchor.constraint(equalTo: workbookTitleLabel.bottomAnchor, constant: 8),
            border.leadingAnchor.constraint(equalTo: workbookTitleLabel.leadingAnchor),
            
            sectionNumLabel.leadingAnchor.constraint(equalTo: border.leadingAnchor),
            sectionNumLabel.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 12),
            
            sectionTitleLabel.leadingAnchor.constraint(equalTo: sectionNumLabel.trailingAnchor, constant: 8),
            sectionTitleLabel.centerYAnchor.constraint(equalTo: sectionNumLabel.centerYAnchor),
            sectionTitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.stackView.addArrangedSubview(view)
    }
    
    private func configureProblemStackView(problems: [Problem_Core]) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        let label = UILabel()
        label.font = .heading5
        label.textColor = .getSemomunColor(.darkGray)
        label.text = "신고할 문제를 선택해주세요"
        stackView.addArrangedSubview(label)
        
        let problemStackView = UIStackView()
        problemStackView.spacing = 8
        
        self.selectProblemButtons = problems.map { problem in
            let button = SelectProblemButton(pName: problem.pName)
            button.addAction(UIAction { [weak self] _ in
                self?.selectProblemButtons.forEach { $0.isSelected = false }
                button.isSelected.toggle()
                self?.selectedPid = Int(problem.pid)
            }, for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            return button
        }
        self.selectProblemButtons.forEach { problemStackView.addArrangedSubview($0) }
        
        stackView.addArrangedSubview(problemStackView)
        
        self.stackView.addArrangedSubview(stackView)
    }
    
    private func configureCategory() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let label = UILabel()
        label.font = .heading5
        label.textColor = .getSemomunColor(.darkGray)
        label.text = "오류에 대해서 알려주세요"
        stackView.addArrangedSubview(label)
        
        let button = ReportButton(title: "\(self.selectedErrorType)")
        let actions = ErrorType.allCases.map { errorType in
            UIAction(title: "\(errorType)") { [weak self] _ in
                 self?.selectedErrorType = errorType
                 button.setTitle("\(errorType)", for: .normal)
             }
        }
        button.menu = .init(title: "오류 유형", children: actions)
        stackView.addArrangedSubview(button)
        
        self.textView.delegate = self
        stackView.addArrangedSubview(self.textView)
        
        self.stackView.addArrangedSubview(stackView)
    }
    
    private func configureLayout() {
        self.view.addSubview(self.backgroundView)
        self.backgroundView.addSubviews(self.titleLabel, self.closeButton, self.stackView, self.reportErrorButton)
        NSLayoutConstraint.activate([
            self.backgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.backgroundView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 24),
            
            self.closeButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 24),
            self.closeButton.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -24),
            
            self.stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 24),
            self.stackView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.closeButton.trailingAnchor),
            
            self.reportErrorButton.topAnchor.constraint(greaterThanOrEqualTo: self.stackView.bottomAnchor),
            self.reportErrorButton.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 24),
            self.reportErrorButton.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor, constant: -24),
            self.reportErrorButton.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -24)
        ])
    }
    
    private func report() {
        guard let pid = self.selectedPid else { return }
        guard (self.selectedErrorType == .others && self.textView.text == nil) == false else { return }
        
        let text = self.selectedErrorType == .others ? self.textView.text! : "\(self.selectedErrorType)"
        
        let networkUsecase = NetworkUsecase(network: Network())
        networkUsecase.postProblemError(error: ErrorReport(pid: pid, content: text)) { [weak self] status in
            switch status {
            case .SUCCESS:
                print("SUCCESS: post error")
            default:
                print("ERROR: post error")
            }
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateReportErrorButtonStatus() {
        guard self.selectedPid != nil else {
            self.reportErrorButton.backgroundColor = .getSemomunColor(.lightGray)
            self.reportErrorButton.isUserInteractionEnabled = false
            return
        }
        
        if self.selectedErrorType == .others {
            if self.textView.text.isEmpty || self.textView.textColor == self.placeholderTextColor {
                self.reportErrorButton.backgroundColor = .getSemomunColor(.lightGray)
                self.reportErrorButton.isUserInteractionEnabled = false
            } else {
                self.reportErrorButton.backgroundColor = .getSemomunColor(.blueRegular)
                self.reportErrorButton.isUserInteractionEnabled = true
            }
        } else {
            self.reportErrorButton.backgroundColor = .getSemomunColor(.blueRegular)
            self.reportErrorButton.isUserInteractionEnabled = true
        }
    }
}

extension ReportProblemErrorVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.updateReportErrorButtonStatus()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == self.placeholderTextColor {
            textView.text = ""
            textView.textColor = .getSemomunColor(.black)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "오류에 대해 입력해주세요"
            textView.textColor = self.placeholderTextColor
        }
    }
}

fileprivate final class SelectProblemButton: UIButton {
    convenience init(pName: String?) {
        self.init(type: .custom)
        self.titleLabel?.font = .heading5
        self.setTitle(pName, for: .normal)
        self.setTitleColor(.getSemomunColor(.black), for: .normal)
        self.setTitleColor(.getSemomunColor(.white), for: .selected)
        self.isSelected = false
        
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.cornerRadius = .cornerRadius4
        self.layer.cornerCurve = .continuous
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.isSelected ? .getSemomunColor(.black) : .getSemomunColor(.background)
        }
    }
}

fileprivate final class ReportButton: UIButton {
    convenience init(title: String) {
        self.init(type: .custom)
        self.showsMenuAsPrimaryAction = true
        self.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .heading5
        self.setTitleColor(.getSemomunColor(.black), for: .normal)
        self.contentHorizontalAlignment = .leading
        self.contentEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 0)
        self.backgroundColor = .getSemomunColor(.background)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        self.layer.cornerRadius = .cornerRadius12
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
        
        let image = UIImage(.chevronDownOutline)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSVGTintColor(.lightGray)
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
