//
//  SlideSectionContentsView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/22.
//

import UIKit

protocol JumpProblemPageDelegate: AnyObject {
    func jumpProblem(pid: Int)
    func closeSlideView()
}

final class SlideSectionContentsView: UIView {
    /* public */
    static let width = CGFloat(320)
    /* private */
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .black)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        button .addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.closeSlideView()
        }), for: .touchUpInside)
        
        return button
    }()
    private var contentFrameview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configureTopCorner(radius: CGFloat.cornerRadius16)
        view.backgroundColor = UIColor.getSemomunColor(.white)
        return view
    }()
    private var workbookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading4
        label.textColor = UIColor.getSemomunColor(.black)
        label.textAlignment = .left
        return label
    }()
    private var underlineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.border)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return view
    }()
    private var backToSectionListButton: UIButton = { // 추후 사용될 버튼
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20)
        ])
        return button
    }()
    private var sectionNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading4
        label.textColor = UIColor.getSemomunColor(.black)
        label.textAlignment = .left
        return label
    }()
    private var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.largeStyleParagraph
        label.textColor = UIColor.getSemomunColor(.darkGray)
        label.textAlignment = .left
        return label
    }()
    private var sectionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private weak var delegate: JumpProblemPageDelegate?
    
    func configure(workbookTitle: String, sectionNum: Int, sectionTitle: String, delegate: JumpProblemPageDelegate) {
        self.delegate = delegate
        self.commonInit(workbookTitle: workbookTitle, sectionNum: sectionNum, sectionTitle: sectionTitle)
        self.configureLayout()
    }
    
    private func commonInit(workbookTitle: String, sectionNum: Int, sectionTitle: String) {
        self.workbookTitleLabel.text = workbookTitle
        self.sectionNumLabel.text = String(format: "%02d", sectionNum)
        self.sectionTitleLabel.text = sectionTitle
    }
    
    private func configureLayout() {
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: SlideSectionContentsView.width)
        ])
        
        self.addSubview(self.closeButton)
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 9),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
        
        self.addSubview(self.contentFrameview)
        NSLayoutConstraint.activate([
            self.contentFrameview.topAnchor.constraint(equalTo: self.topAnchor, constant: 42),
            self.contentFrameview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentFrameview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentFrameview.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.contentFrameview.addSubview(self.workbookTitleLabel)
        NSLayoutConstraint.activate([
            self.workbookTitleLabel.topAnchor.constraint(equalTo: self.contentFrameview.topAnchor, constant: 16),
            self.workbookTitleLabel.leadingAnchor.constraint(equalTo: self.contentFrameview.leadingAnchor, constant: 16),
            self.workbookTitleLabel.trailingAnchor.constraint(equalTo: self.contentFrameview.trailingAnchor, constant: -16)
        ])
        
        self.contentFrameview.addSubview(self.underlineView)
        NSLayoutConstraint.activate([
            self.underlineView.topAnchor.constraint(equalTo: self.workbookTitleLabel.bottomAnchor, constant: 16),
            self.underlineView.leadingAnchor.constraint(equalTo: self.workbookTitleLabel.leadingAnchor),
            self.underlineView.trailingAnchor.constraint(equalTo: self.workbookTitleLabel.trailingAnchor)
        ])
        
        self.sectionStackView.addArrangedSubview(self.backToSectionListButton)
        self.sectionStackView.addArrangedSubview(self.sectionNumLabel)
        self.sectionStackView.addArrangedSubview(self.sectionTitleLabel)
        self.contentFrameview.addSubview(self.sectionStackView)
        NSLayoutConstraint.activate([
            self.sectionStackView.topAnchor.constraint(equalTo: self.underlineView.bottomAnchor, constant: 16),
            self.sectionStackView.leadingAnchor.constraint(equalTo: self.underlineView.leadingAnchor),
            self.sectionStackView.trailingAnchor.constraint(equalTo: self.underlineView.trailingAnchor)
        ])
    }
}
