//
//  NoticePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/22.
//

import UIKit

final class NoticePopupVC: UIViewController {
    private var imageURL: URL
    
    private let xmarkImage: UIImage = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(.xmark, withConfiguration: largeConfig)
    }()
    
    private lazy var noticeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(.noticeImage)
        return imageView
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
    
    private lazy var doNotShowAgainButton: UIButton = {
        let button = UIButton()
        
        let checkbox = UIImageView(image: UIImage(systemName: "square"))
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.tintColor = .white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        let underlineAttriString = NSAttributedString(
            string: "다시 보지 않기",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        label.attributedText = underlineAttriString
        
        button.addSubviews(label, checkbox)
        NSLayoutConstraint.activate([
            checkbox.widthAnchor.constraint(equalToConstant: 18),
            checkbox.heightAnchor.constraint(equalToConstant: 18),
            
            checkbox.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            checkbox.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            
            checkbox.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10)
        ])
        
        var doNotShow = false
        button.addAction(UIAction(handler: { [weak self] _ in
            doNotShow.toggle()
            if doNotShow {
                UserDefaultsManager.lastViewedPopup = self?.imageURL.absoluteString
                checkbox.image = UIImage(systemName: "checkmark.square.fill")
            } else {
                UserDefaultsManager.lastViewedPopup = ""
                checkbox.image = UIImage(systemName: "square")
            }
        }), for: .touchUpInside)
        
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(url: URL) {
        self.imageURL = url
        super.init(nibName: nil, bundle: nil)
        self.noticeImageView.kf.setImage(with: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.noticeImageView, self.closeButton, self.doNotShowAgainButton)
        NSLayoutConstraint.activate([
            self.noticeImageView.widthAnchor.constraint(equalToConstant: 520),
            self.noticeImageView.heightAnchor.constraint(equalToConstant: 656.3),
            self.noticeImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.noticeImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.topAnchor.constraint(equalTo: self.noticeImageView.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.noticeImageView.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            self.doNotShowAgainButton.centerXAnchor.constraint(equalTo: self.noticeImageView.centerXAnchor),
            self.doNotShowAgainButton.bottomAnchor.constraint(equalTo: self.noticeImageView.bottomAnchor, constant: -24),
            self.doNotShowAgainButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
