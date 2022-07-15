//
//  ProfileRows.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/15.
//

import UIKit

class ProfileSectionRow: UIView {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.textColor = .getSemomunColor(.lightGray)
        return label
    }()
    init(text: String) {
        super.init(frame: .zero)
        self.label.text = text
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 66),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileLinkRow: UIControl {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .largeStyleParagraph
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    let imageView: UIImageView = {
        let image = UIImage(.chevronRightOutline)
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setSVGTintColor(to: .getSemomunColor(.lightGray))
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 20),
            view.heightAnchor.constraint(equalToConstant: 20)
        ])
        return view
    }()
    init(text: String, action: @escaping () -> Void) {
        super.init(frame: .zero)
        self.label.text = text
        self.addSubviews(self.label, self.imageView)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 44),
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        self.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileRowWithSubtitle: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .largeStyleParagraph
        label.textColor = .getSemomunColor(.darkGray)
        return label
    }()
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .largeStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        return label
    }()
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.addSubviews(self.titleLabel, self.subtitleLabel)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 44),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.subtitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileRowDivider: UIView {
    convenience init() {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.backgroundColor = .getSemomunColor(.border)
    }
}

