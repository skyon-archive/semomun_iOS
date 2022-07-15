//
//  SegmentedControlView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import UIKit

struct SegmentedButtonInfo {
    let title: String
    var action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

final class SegmentedControlView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    convenience init(buttons: [SegmentedButtonInfo]) {
        self.init(frame: CGRect())
        self.commonInit(buttons)
    }
    
    private func commonInit(_ buttonInfos: [SegmentedButtonInfo]) {
        for (idx, info) in buttonInfos.enumerated() {
            self.stackView.addArrangedSubview(SegmentedButton(info: info, action: { [weak self] in
                self?.selectIndex(to: idx)
            }))
        }
        self.selectIndex(to: 0)
        self.addSubview(self.stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
        self.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.layer.cornerCurve = .continuous
        self.backgroundColor = UIColor.getSemomunColor(.background)
    }
    
    func selectIndex(to index: Int) {
        for (idx, button) in self.stackView.subviews.enumerated() {
            if let button = button as? SegmentedButton {
                if idx == index {
                    button.select()
                } else {
                    button.deSelect()
                }
            }
        }
    }
}

final class SegmentedButton: UIButton {
    convenience init(info: SegmentedButtonInfo, action: @escaping () -> Void) {
        self.init(type: .custom)
        self.commonInit(info, action)
    }
    
    private func commonInit(_ info: SegmentedButtonInfo, _ action: @escaping () -> Void) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.font = UIFont.heading5
        self.titleLabel?.textColor = UIColor.getSemomunColor(.lightGray)
        self.setTitle(info.title, for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 14
        self.layer.cornerCurve = .continuous
        self.addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
    }
    
    func select() {
        self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        self.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
    }
    
    func deSelect() {
        self.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
        self.backgroundColor = UIColor.clear
    }
}
