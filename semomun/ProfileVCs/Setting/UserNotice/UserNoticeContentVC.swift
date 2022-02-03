//
//  UserNoticeContentVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import Foundation
import UIKit

final class UserNoticeContentVC: UIViewController {
    private let backgroundFrame = UIView()
    private let contentTextView = UITextView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: SemomunColor.grayTextColor)
        return label
    }()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: SemomunColor.divider)
        return view
    }()
    private let textViewAttribute: [NSAttributedString.Key : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1
        let attributes = [
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        return attributes
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "공지사항"
        self.configureLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backgroundFrame.addShadow(direction: .top)
    }
    
    func configureContent(using userNotice: UserNotice) {
        self.titleLabel.text = userNotice.title
        self.dateLabel.text = userNotice.date.yearMonthDayText
        self.contentTextView.attributedText = NSAttributedString(string: userNotice.content, attributes: textViewAttribute)
    }
}

// MARK: Configure layout
extension UserNoticeContentVC {
    private func configureLayout() {
        self.configureBackgroundLayout()
        self.configureHeaderLayout()
        self.configureTextViewLayout()
    }
    
    private func configureBackgroundLayout() {
        self.configureBackgroundColorView()
        self.configureBackgroundShadowView()
    }
    
    private func configureBackgroundColorView() {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(named: SemomunColor.lightGrayBackgroundColor)
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundColorView)
        NSLayoutConstraint.activate([
            backgroundColorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            backgroundColorView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            backgroundColorView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureBackgroundShadowView() {
        self.backgroundFrame.backgroundColor = .white
        self.backgroundFrame.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.backgroundFrame)
        NSLayoutConstraint.activate([
            self.backgroundFrame.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundFrame.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundFrame.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundFrame.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func configureHeaderLayout() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundFrame.leadingAnchor, constant: 107),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundFrame.topAnchor, constant: 27)
        ])
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            self.dateLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4)
        ])
        
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(divider)
        NSLayoutConstraint.activate([
            self.divider.heightAnchor.constraint(equalToConstant: 1),
            self.divider.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.divider.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 16),
            self.divider.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32)
        ])
    }
    
    private func configureTextViewLayout() {
        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.contentTextView)
        NSLayoutConstraint.activate([
            self.contentTextView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.contentTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 107),
            self.contentTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.contentTextView.topAnchor.constraint(equalTo: self.divider.bottomAnchor, constant: 37)
        ])
    }
}
