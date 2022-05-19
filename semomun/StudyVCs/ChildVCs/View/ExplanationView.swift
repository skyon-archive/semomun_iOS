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
    private var contentViewHeightConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
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
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        self.scrollView.addSubview(self.contentView)
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        self.contentViewHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: self.imageviewHeight)
        self.contentViewHeightConstraint?.isActive = true
        
        
        self.contentView.addSubview(self.explanationImageView)
        NSLayoutConstraint.activate([
            self.explanationImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.explanationImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.explanationImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
        
        self.imageViewHeightConstraint = self.explanationImageView.heightAnchor.constraint(equalToConstant: self.imageviewHeight)
        self.imageViewHeightConstraint?.isActive = true
    }
    
    func configureImage(to image: UIImage?) {
        self.layoutIfNeeded()
        guard let image = image else { return }
        let width = self.scrollView.frame.width
        let height = image.size.height*(width/image.size.width)
        self.imageViewHeightConstraint?.constant = height
        self.contentViewHeightConstraint?.constant = height
        self.explanationImageView.image = image
        self.scrollView.setContentOffset(.zero, animated: false)
    }
    
    func updateLayout() {
        self.layoutIfNeeded()
        guard let imageSize = self.explanationImageView.image?.size else { return }
        
        NSLayoutConstraint.deactivate([self.imageViewHeightConstraint, self.contentViewHeightConstraint])
        let height = imageSize.height*(self.scrollView.bounds.width)/imageSize.width
        self.imageViewHeightConstraint = self.explanationImageView.heightAnchor.constraint(equalToConstant: height)
        self.contentViewHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: height)
        NSLayoutConstraint.activate([self.imageViewHeightConstraint, self.contentViewHeightConstraint])
    }
}
