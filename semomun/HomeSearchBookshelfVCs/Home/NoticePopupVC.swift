//
//  NoticePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/22.
//

import UIKit

final class NoticePopupVC: UIViewController {
    private var noticeTitle: String
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
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.5, weight: .bold)
        label.text = self.noticeTitle
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String) {
        self.noticeTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.noticeImageView, self.titleLabel, self.closeButton)
        NSLayoutConstraint.activate([
            self.noticeImageView.widthAnchor.constraint(equalToConstant: 520),
            self.noticeImageView.heightAnchor.constraint(equalToConstant: 656.3),
            self.noticeImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.noticeImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.noticeImageView.topAnchor, constant: 164),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.noticeImageView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.topAnchor.constraint(equalTo: self.noticeImageView.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.noticeImageView.trailingAnchor, constant: -15)
        ])
    }
}
