//
//  UserNoticeContentVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import Foundation
import UIKit

final class UserNoticeContentVC: UIViewController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private let contentTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isSelectable = false
        view.textColor = .getSemomunColor(.darkGray)
        view.textContainerInset = .init(top: 16, left: 32, bottom: 16, right: 32)
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        return label
    }()
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.border)
        return view
    }()
    
    init(userNotice: UserNotice) {
        super.init(nibName: nil, bundle: nil)
        self.configureUI()
        self.configureLayout()
        self.titleLabel.text = userNotice.title
        self.dateLabel.text = userNotice.createdDate.yearMonthDayText
        self.configureTextView(text: userNotice.text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserNoticeContentVC {
    private func configureUI() {
        self.view.backgroundColor = .getSemomunColor(.background)
        self.navigationItem.title = "공지사항"
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.backgroundView, self.titleLabel, self.dateLabel, self.divider, self.contentTextView)
        NSLayoutConstraint.activate([
            self.backgroundView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 32),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundView.topAnchor, constant: 40),
            
            self.dateLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            
            self.divider.heightAnchor.constraint(equalToConstant: 1),
            self.divider.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor),
            self.divider.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 16),
            self.divider.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            
            self.contentTextView.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor),
            self.contentTextView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor),
            self.contentTextView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor),
            self.contentTextView.topAnchor.constraint(equalTo: self.divider.bottomAnchor)
        ])
    }
    
    private func configureTextView(text: String) {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 2
        let attributes = [
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.font: UIFont.regularStyleParagraph
        ]
        self.contentTextView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
