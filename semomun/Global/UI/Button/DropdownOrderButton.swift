//
//  DropdownOrderButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/06.
//

import UIKit

final class DropdownOrderButton: UIButton {
    enum Order: String {
        case recentRead = "최근 읽은 순"
        case recentUpload = "최근 등록순"
        case recentPurchase = "최근 구매일순"
        case titleDescending = "제목 내림차순"
        case titleAscending = "제목 오름차순"
    }
    
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.chevronDownOutline).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.getSemomunColor(.lightGray)
        return imageView
    }()

    convenience init(order: Order) {
        self.init(type: .custom)
        self.commonInit(order: order)
    }
    
    private func commonInit(order: Order) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(.sortDescendingOutline).withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.getSemomunColor(.black)
        self.setImage(image, for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 40)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.titleLabel?.font = UIFont.heading5
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat.cornerRadius12
        
        self.addAction(UIAction(handler: { [weak self] _ in
            self?.changeOrder(to: .recentPurchase)
        }), for: .touchUpInside)
        
        self.addSubview(self.rightIcon)
        NSLayoutConstraint.activate([
            self.rightIcon.widthAnchor.constraint(equalToConstant: 20),
            self.rightIcon.heightAnchor.constraint(equalToConstant: 20),
            self.rightIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.rightIcon.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        ])
        
        self.setTitle(order.rawValue, for: .normal)
    }
    
    func changeOrder(to order: Order) {
        self.setTitle(order.rawValue, for: .normal)
    }
}
