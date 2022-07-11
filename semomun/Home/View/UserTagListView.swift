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
    func updateTagList(tagNames: [String]) {
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        tagNames.forEach { name in
            let tagView = self.makeTagView(withName: name)
            self.stackView.addArrangedSubview(tagView)
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
    
    private func makeTagView(withName name: String) -> UIView {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .heading5
        view.text = name
        view.backgroundColor = UIColor.getSemomunColor(.white)
        view.borderWidth = 1
        view.borderColor = UIColor.getSemomunColor(.border)
        view.textAlignment = .center
        view.layer.cornerRadius = .cornerRadius12
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        
        // 16은 텍스트 양쪽에서 셀 가장자리까지의 거리
        let width = name.size(withAttributes: [.font: UIFont.heading5]).width + (16 * 2)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return view
    }
}
