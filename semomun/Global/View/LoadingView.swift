//
//  LoadingView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import UIKit

final class LoadingView: UIView {
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .getSemomunColor(.darkGray)
        return loader
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.addSubview(self.loader)
        self.backgroundColor = .getSemomunColor(.background)
        self.alpha = 0.5
        
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func start() {
        self.loader.startAnimating()
        self.isHidden = false
    }
    
    func stop() {
        self.loader.stopAnimating()
        self.isHidden = true
    }
}
