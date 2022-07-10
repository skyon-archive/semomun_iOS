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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.statusOfflineSolid)
        imageView.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 43.2),
            imageView.heightAnchor.constraint(equalToConstant: 38.4)
        ])
        
        return imageView
    }()
    private lazy var warningTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.getSemomunColor(.lightGray)
        label.font = UIFont.heading5
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "인터넷 연결을 확인해주세요.\n오프라인 상태에서는 다운로드 한 콘텐츠만 이용할 수 있어요."
        
        return label
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.backgroundColor = .white
        
        let frameView = UIView()
        self.addSubview(frameView)
        
        frameView.translatesAutoresizingMaskIntoConstraints = false
        let frameViewLayouts = [
            frameView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        frameView.addSubviews(self.iconImageView, self.warningTextLabel)
        
        let iconImageViewLayouts = [
            self.iconImageView.topAnchor.constraint(equalTo: frameView.topAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
        ]
        
        let warningTextLabelLayouts = [
            self.warningTextLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 8),
            self.warningTextLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.warningTextLabel.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            self.warningTextLabel.trailingAnchor.constraint(equalTo: frameView.trailingAnchor)
        ]
        
        self.layoutConstraintActivates(frameViewLayouts, iconImageViewLayouts, warningTextLabelLayouts)
    }
}
