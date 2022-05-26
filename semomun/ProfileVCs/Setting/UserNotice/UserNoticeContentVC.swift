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
    private let contentTextView: UITextView = {
       let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.black
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(.grayTextColor)
        return label
    }()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.divider)
        return view
    }()
    private let textViewAttribute: [NSAttributedString.Key : Any] = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 2
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
    
    func configureContent(using userNotice: UserNotice) {
        self.titleLabel.text = userNotice.title
        self.dateLabel.text = userNotice.createdDate.yearMonthDayText
        self.contentTextView.attributedText = NSAttributedString(string: userNotice.text, attributes: textViewAttribute)
    }
}

// MARK: Configure layout
extension UserNoticeContentVC {
    private func configureLayout() {
        self.layoutBackgroundColorView()
        self.layoutBackgroundFrame()
        self.layoutHeader()
        self.layoutTextView()
    }
    
    private func layoutBackgroundColorView() {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(.lightGrayBackgroundColor)
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundColorView)
        NSLayoutConstraint.activate([
            backgroundColorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            backgroundColorView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            backgroundColorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    private func layoutBackgroundFrame() {
        self.backgroundFrame.backgroundColor = .white
        self.backgroundFrame.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.backgroundFrame)
        NSLayoutConstraint.activate([
            self.backgroundFrame.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundFrame.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundFrame.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.backgroundFrame.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func layoutHeader() {
        self.view.addSubviews(self.titleLabel, self.dateLabel, self.divider)
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundFrame.leadingAnchor, constant: 28),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundFrame.topAnchor, constant: 27)
        ])
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.dateLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4)
        ])
        
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.divider.heightAnchor.constraint(equalToConstant: 1),
            self.divider.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.divider.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 16),
            self.divider.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
    
    private func layoutTextView() {
        self.contentTextView.textContainerInset = UIEdgeInsets(top: 37, left: 28, bottom: 28, right: 37)
        
        self.view.addSubview(self.contentTextView)
        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentTextView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.contentTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.contentTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.contentTextView.topAnchor.constraint(equalTo: self.divider.bottomAnchor)
        ])
    }
}
