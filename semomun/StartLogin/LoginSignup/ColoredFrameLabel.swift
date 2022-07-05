//
//  BottomFrameStateLabel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/09.
//

import UIKit

final class ColoredFrameLabel: UIView {

    private let imageView = UIImageView()
    private let textLabel = UILabel()
    
    enum Content {
        case success(String), warning(String)
    }
    
    init() {
        super.init(frame: CGRect())
        textLabel.font = .systemFont(ofSize: 12, weight: .regular)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviews(imageView, textLabel)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 17),
            imageView.heightAnchor.constraint(equalToConstant: 17),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func configure(type: Content) {
        self.isHidden = false
        
        let imageSystemName: SemomunImage
        let message: String
        let tintColor: UIColor
        
        switch type {
        case .success(let string):
            imageSystemName = .circleCheckmark
            tintColor = UIColor(.blueRegular) ?? .green
            message = string
        case .warning(let string):
            imageSystemName = .exclamationmarkTriangle
            tintColor = UIColor(.orangeRegular) ?? .red
            message = string
        }
        
        let image = UIImage(imageSystemName)
        self.imageView.image = image
        imageView.tintColor = tintColor
        
        textLabel.text = message
        textLabel.textColor = tintColor
    }
}
