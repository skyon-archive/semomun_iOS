//
//  DropdownButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit

final class DropdownButton: UIButton {
    enum BookshelfSubject: String, CaseIterable {
        case all = "모든 과목"
        case kor = "국어"
        case math = "수학"
        case eng = "영어"
        case soc = "사회"
        case sci = "과학"
    }
    
    private lazy var rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.chevronDownOutline).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.getSemomunColor(.lightGray)
        return imageView
    }()

    convenience init() {
        self.init(type: .custom)
        self.commonInit()
    }
    
    private func commonInit() {
        self.setImageWithSVGTintColor(semomunImage: .chevronDownOutline, color: .lightGray)
        self.semanticContentAttribute = .forceRightToLeft
        self.tintColor = UIColor.getSemomunColor(.black)
        self.titleLabel?.font = UIFont.heading5
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat.cornerRadius12
        self.setTitle("모든 과목", for: .normal)
        self.showsMenuAsPrimaryAction = true
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 40)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configureBookshelfMenu(action: @escaping (BookshelfSubject) -> Void) {
        let actions = BookshelfSubject.allCases.map { order in
            UIAction(title: order.rawValue, image: nil) { [weak self] _ in
                self?.setTitle(order.rawValue, for: .normal)
                action(order)
            }
        }
        self.menu = UIMenu(title: "정렬 기준", image: nil, children: actions)
    }
    
    func changeOrder(to order: BookshelfSubject) {
        self.setTitle(order.rawValue, for: .normal)
    }
}
