//
//  ExplanationView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/06.
//

import UIKit

protocol ExplanationRemover: AnyObject {
    func closeExplanation()
}

final class ExplanationView: UIView {
    private weak var delegate: ExplanationRemover?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    private lazy var imageviewHeight: CGFloat = (self.frame.height/2)-40
    private let xmarkImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(.xmark, withConfiguration: largeConfig)
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private lazy var explanationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.xmarkImage, for: .normal)
        button.tintColor = .black
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.closeExplanation()
        }), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    func configureDelegate(to delegate: ExplanationRemover) {
        self.delegate = delegate
    }
    
    private func configureLayout() {
        self.addSubviews(self.scrollView, self.closeButton)
        self.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 100),
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.scrollView.addSubview(self.explanationImageView)
        NSLayoutConstraint.activate([
            self.explanationImageView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.explanationImageView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.explanationImageView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.explanationImageView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.explanationImageView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        self.imageViewHeightConstraint = self.explanationImageView.heightAnchor.constraint(equalToConstant: self.imageviewHeight)
        self.imageViewHeightConstraint?.isActive = false
    }
    
    func configureImage(to image: UIImage?) {
        self.layoutIfNeeded()
        guard let image = image else { return }
        let width = self.scrollView.frame.width
        let height = image.size.height*(width/image.size.width)
        self.imageViewHeightConstraint?.constant = height
        self.explanationImageView.image = image
    }
}
