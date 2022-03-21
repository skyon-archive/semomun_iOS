//
//  NoticePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/22.
//

import UIKit

final class NoticePopupVC: UIViewController {
    private lazy var noticeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(.noticeImage)
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.noticeImageView)
        NSLayoutConstraint.activate([
            self.noticeImageView.widthAnchor.constraint(equalToConstant: 450),
            self.noticeImageView.heightAnchor.constraint(equalToConstant: 568),
            self.noticeImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.noticeImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
