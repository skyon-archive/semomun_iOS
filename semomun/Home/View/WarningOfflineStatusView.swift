//
//  OfflineAlertView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/15.
//

import UIKit

final class WarningOfflineStatusView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(.warning)
        return imageView
    }()
    private lazy var warningTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.text = "네트워크가 연결되어 있지 않습니다."
        return label
    }()
    private lazy var warningTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let string = "인터넷 연결을 확인한 후 다시 시도해 주세요.\n<책장>에서 구매 후 다운로드 받으신 콘텐츠는 이용 가능합니다."
        let attributedString = NSMutableAttributedString(string: string)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: string.count))
        label.attributedText = attributedString
        
        return label
    }()
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor = UIColor(.blueRegular)
        button.setTitle(" 다시시도", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setImage(UIImage(.warning), for: .normal)
        
        button.addAction(UIAction(handler: { _ in
            NotificationCenter.default.post(name: .checkHomeNetworkFetchable, object: nil)
        }), for: .touchUpInside)
        return button
    }()
    private lazy var goBookshelfButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor = UIColor(.blueRegular)
        button.setTitle("책장으로 가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        button.addAction(UIAction(handler: { _ in
            NotificationCenter.default.post(name: .goToBookShelf, object: nil)
        }), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        
        let frameView = UIView()
        self.addSubview(frameView)
        
        frameView.translatesAutoresizingMaskIntoConstraints = false
        let frameViewLayouts = [
            frameView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        let buttons = UIStackView(arrangedSubviews: [self.refreshButton, self.goBookshelfButton])
        buttons.distribution = .fillEqually
        buttons.spacing = 10
        frameView.addSubviews(self.iconImageView, self.warningTitleLabel, self.warningTextLabel, buttons)
        
        let iconImageViewLayouts = [
            self.iconImageView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 5),
            self.iconImageView.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 96),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 58)
        ]
        
        let warningTitleLabelLayouts = [
            self.warningTitleLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 20),
            self.warningTitleLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor)
        ]
        
        let warningTextLabelLayouts = [
            self.warningTextLabel.topAnchor.constraint(equalTo: self.warningTitleLabel.bottomAnchor, constant: 8),
            self.warningTextLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.warningTextLabel.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: 5),
            self.warningTextLabel.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: -5)
        ]
        
        buttons.translatesAutoresizingMaskIntoConstraints = false
        let buttonsLayout = [
            buttons.topAnchor.constraint(equalTo: self.warningTextLabel.bottomAnchor, constant: 31),
            buttons.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            buttons.widthAnchor.constraint(equalToConstant: 244),
            buttons.heightAnchor.constraint(equalToConstant: 33),
            buttons.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -5)
        ]
        
        self.layoutConstraintActivates(frameViewLayouts,
                                       iconImageViewLayouts,
                                       warningTitleLabelLayouts,
                                       warningTextLabelLayouts,
                                       buttonsLayout)
    }
}
