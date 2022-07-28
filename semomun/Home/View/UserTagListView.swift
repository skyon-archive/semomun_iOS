//
//  UserTagListView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/08.
//

import UIKit

final class UserTagListView: UIView {
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 12
        view.distribution = .equalSpacing
        
        return view
    }()
    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImageWithSVGTintColor(image: UIImage(.pencilSolid), color: .black)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 32),
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayout()
    }
    
    // MARK: 반드시 호출해야하는 메소드
    func updateTagList(tags: [TagOfDB]) {
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        tags.forEach { tag in
            // MARK: 임시 변수
            let tagLabel = TagLabel(categoryName: "테스트", tagName: tag.name)
            self.stackView.addArrangedSubview(tagLabel)
        }
    }
    
    // MARK: 반드시 호출해야하는 메소드
    func configureEditButtonAction(action: @escaping () -> Void) {
        self.editButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
}

extension UserTagListView {
    private func configureLayout() {
        self.addSubviews(self.scrollView, self.editButton)
        self.scrollView.addSubview(self.stackView)
        
        let editButtonLeadingConstraint = self.editButton.leadingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: 12)
        editButtonLeadingConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 32),
            
            self.scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            // editButton의 width(32)만큼의 여백을 추가로 남김
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12-32),
            self.scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: self.heightAnchor),
            
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            
            self.editButton.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor),
            self.editButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            editButtonLeadingConstraint
        ])
    }
}

fileprivate final class TagLabel: UILabel {
    convenience init(categoryName: String, tagName: String) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .heading5
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.borderWidth = 1
        self.borderColor = UIColor.getSemomunColor(.border)
        self.textAlignment = .center
        self.layer.cornerRadius = .cornerRadius12
        self.layer.masksToBounds = true
        self.layer.cornerCurve = .continuous
        
        let text = self.makeAttributedText(categoryName: categoryName, tagName: tagName)
        self.attributedText = text
        
        // 16은 텍스트 양쪽에서 셀 가장자리까지의 거리
        let width = text.size().width + (16 * 2)
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func makeAttributedText(categoryName: String, tagName: String) -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(NSMutableAttributedString(string: categoryName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.darkGray),
            NSAttributedString.Key.font: UIFont.heading4
        ]))
        text.append(NSMutableAttributedString(string: " / ", attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.lightGray),
            NSAttributedString.Key.font: UIFont.heading5
        ]))
        text.append(NSMutableAttributedString(string: tagName, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.black),
            NSAttributedString.Key.font: UIFont.heading4
        ]))
        return text
    }
}
