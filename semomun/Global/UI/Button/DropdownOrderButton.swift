//
//  DropdownOrderButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/06.
//

import UIKit

final class DropdownOrderButton: UIButton {
    enum SearchOrder: String, CaseIterable {
        case recentUpload = "최근 등록순"
        case titleAscending = "제목 오름차순"
        case titleDescending = "제목 내림차순"
        
        var param : String {
            switch self {
            case .recentUpload: return "recentUpload"
            case .titleDescending: return "titleDescending"
            case .titleAscending: return "titleAscending"
            }
        }
    }
    enum BookshelfOrder: String, CaseIterable {
        case recentRead = "최근 읽은 순"
        case recentPurchase = "최근 구매일순"
        case titleAscending = "제목 오름차순"
        case titleDescending = "제목 내림차순"
    }
    
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.chevronDownOutline).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.getSemomunColor(.lightGray)
        return imageView
    }()

    convenience init(order: BookshelfOrder) {
        self.init(type: .custom)
        self.commonInit(orderString: order.rawValue)
    }
    
    convenience init(order: SearchOrder) {
        self.init(type: .custom)
        self.commonInit(orderString: order.rawValue)
    }
    
    private func commonInit(orderString: String) {
        let image = UIImage(.sortDescendingOutline).withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.getSemomunColor(.black)
        self.setImage(image, for: .normal)
        self.titleLabel?.font = UIFont.heading5
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat.cornerRadius12
        self.setTitle(orderString, for: .normal)
        self.showsMenuAsPrimaryAction = true
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 40)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        self.addSubview(self.rightIcon)
        NSLayoutConstraint.activate([
            self.rightIcon.widthAnchor.constraint(equalToConstant: 20),
            self.rightIcon.heightAnchor.constraint(equalToConstant: 20),
            self.rightIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.rightIcon.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            
            self.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configureSearchMenu(action: @escaping (SearchOrder) -> Void) {
        let actions = SearchOrder.allCases.map { order in
            UIAction(title: order.rawValue, image: nil) { [weak self] _ in
                self?.setTitle(order.rawValue, for: .normal)
                action(order)
            }
        }
        self.menu = UIMenu(title: "정렬 기준", image: nil, children: actions)
    }
    
    func configureBookshelfMenu(action: @escaping (BookshelfOrder) -> Void) {
        let actions = BookshelfOrder.allCases.map { order in
            UIAction(title: order.rawValue, image: nil) { [weak self] _ in
                self?.setTitle(order.rawValue, for: .normal)
                action(order)
            }
        }
        self.menu = UIMenu(title: "정렬 기준", image: nil, children: actions)
    }
    
    func changeOrder(to order: BookshelfOrder) {
        self.setTitle(order.rawValue, for: .normal)
    }
    
    func changeOrder(to order: SearchOrder) {
        self.setTitle(order.rawValue, for: .normal)
    }
}
