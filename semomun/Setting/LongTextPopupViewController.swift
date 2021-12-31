//
//  LongTextPopupViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/31.
//

import UIKit

final class LongTextPopupViewController: UIViewController {
    static let identifier = "LongTextPopupViewController"
    
    private var titleText: String?
    private var text: String?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        textView.textColor = .black
        textView.isEditable = false
        textView.isSecureTextEntry = true
        return textView
    }()
    
    init(title: String, text: String) {
        self.titleText = title
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.titleText = nil
        self.text = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.titleLabel, self.textView)
        self.configureTitle()
        self.configureText()
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.textView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15)
        ])
    }
    
    private func configureTitle() {
        guard let titleText = self.titleText else { return }
        self.titleLabel.text = titleText
    }
    
    private func configureText() {
        guard let text = self.text else { return }
        self.textView.text = text
    }
}
