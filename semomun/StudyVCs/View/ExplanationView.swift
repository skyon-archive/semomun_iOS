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
    private let xmarkImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .default)
        return UIImage(systemName: SemomunImage.xmark, withConfiguration: largeConfig)
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private lazy var explanationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    func configureImage(to image: UIImage?) {
//        guard let image = image else { return }
//        self.explanationImageView.image = image
    }

}
