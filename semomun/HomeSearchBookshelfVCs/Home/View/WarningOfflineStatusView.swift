//
//  OfflineAlertView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/15.
//

import Foundation
import UIKit

final class WarningOfflineStatusView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(.offlineAlert)
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
        label.text = "인터넷 연결을 확인한 후 다시 시도해 주세요."
        return label
    }()
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor = UIColor(.mainColor)
        button.setTitle("새로고침", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.addAction(UIAction(handler: { _ in
            NotificationCenter.default.post(name: .checkHomeNetworkFetchable, object: nil)
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
        
        frameView.addSubviews(self.iconImageView, self.warningTitleLabel, self.warningTextLabel, self.refreshButton)
        
        let iconImageViewLayouts = [
            self.iconImageView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 5),
            self.iconImageView.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 74),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 38)
        ]
        
        let warningTitleLabelLayouts = [
            self.warningTitleLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 23),
            self.warningTitleLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor)
        ]
        
        let warningTextLabelLayouts = [
            self.warningTextLabel.topAnchor.constraint(equalTo: self.warningTitleLabel.bottomAnchor, constant: 6),
            self.warningTextLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.warningTextLabel.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: 5),
            self.warningTextLabel.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: -5)
        ]
        
        let refreshButtonLayouts = [
            self.refreshButton.topAnchor.constraint(equalTo: self.warningTextLabel.bottomAnchor, constant: 31),
            self.refreshButton.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.refreshButton.widthAnchor.constraint(equalToConstant: 110),
            self.refreshButton.heightAnchor.constraint(equalToConstant: 33),
            self.refreshButton.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -5)
        ]
    
        self.layoutConstraintActivates(frameViewLayouts,
                                       iconImageViewLayouts,
                                       warningTitleLabelLayouts,
                                       warningTextLabelLayouts,
                                       refreshButtonLayouts)
    }
}
