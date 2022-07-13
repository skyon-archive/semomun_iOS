//
//  SegmentedControlView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/12.
//

import UIKit

struct SegmentedButtonInfo {
    let title: String
    let count: Int
    var action: () -> Void
    
    init(title: String, count: Int, action: @escaping () -> Void) {
        self.title = title
        self.count = count
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
    
    func updateCount(index: Int, to count: Int) {
        if let targetButton = self.stackView.subviews[safe: index] as? SegmentedButton {
            targetButton.updateCount(to: count)
        }
    }
}

final class SegmentedButton: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        return label
    }()
    private var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.smallStyleParagraph
        label.textColor = UIColor.getSemomunColor(.lightGray)
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.countLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    convenience init(info: SegmentedButtonInfo, action: @escaping () -> Void) {
        self.init(frame: CGRect())
        self.commonInit(info, action)
    }
    
    private func commonInit(_ info: SegmentedButtonInfo, _ action: @escaping () -> Void) {
        self.titleLabel.text = info.title
        self.countLabel.text = "\(info.count)"
        
        self.addSubview(self.stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 28),
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        ])
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 14
        self.layer.cornerCurve = .continuous
        self.backgroundColor = UIColor.clear
        
        self.isUserInteractionEnabled = true
        let click = ClickListener {
            info.action()
            action()
        }
        self.addGestureRecognizer(click)
    }
    
    func updateCount(to count: Int) {
        self.countLabel.text = "\(count)"
    }
    
    func select() {
        self.titleLabel.textColor = UIColor.getSemomunColor(.blueRegular)
        self.countLabel.textColor = UIColor.getSemomunColor(.darkGray)
        self.backgroundColor = UIColor.getSemomunColor(.white)
    }
    
    func deSelect() {
        self.titleLabel.textColor = UIColor.getSemomunColor(.lightGray)
        self.countLabel.textColor = UIColor.getSemomunColor(.lightGray)
        self.backgroundColor = UIColor.clear
    }
}

final class ClickListener: UITapGestureRecognizer {
    private var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
