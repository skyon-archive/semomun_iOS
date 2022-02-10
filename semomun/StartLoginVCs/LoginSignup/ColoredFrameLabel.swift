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
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5)
        ])
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func configure(type: Content) {
        self.isHidden = false
        
        let imageSystemName: String
        let message: String
        let tintColor: UIColor
        
        switch type {
        case .success(let string):
            imageSystemName = SemomunImage.circleCheckmark
            tintColor = UIColor(.greenColor) ?? .green
            message = string
        case .warning(let string):
            imageSystemName = SemomunImage.exclamationmarkTriangle
            tintColor = UIColor(.redColor) ?? .red
            message = string
        }
        
        let image = UIImage(systemName: imageSystemName)
        self.imageView.image = image
        imageView.tintColor = tintColor
        
        textLabel.text = message
        textLabel.textColor = tintColor
    }
}
