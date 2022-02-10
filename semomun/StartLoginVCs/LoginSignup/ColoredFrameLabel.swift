//
//  BottomFrameStateLabel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/09.
//

import UIKit

final class ColoredFrameLabel: UIView {
    private static let tag = 100
    
    enum Content {
        case success(String), warning(String)
    }
    
    init(withMessage message: String, type: Content) {
        super.init(frame: CGRect())
        self.tag = Self.tag
        
        let imageSystemName: String
        let tintColor: UIColor
        if case .success = type {
            imageSystemName = SemomunImage.circleCheckmark
            tintColor = UIColor(.greenColor) ?? .green
        } else {
            imageSystemName = SemomunImage.exclamationmarkTriangle
            tintColor = UIColor(.redColor) ?? .red
        }
        
        let image = UIImage(systemName: imageSystemName)
        let imageView = UIImageView(image: image)
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.font = .systemFont(ofSize: 12, weight: .regular)
        textLabel.text = message
        textLabel.textColor = tintColor
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
    
    func attach(to frame: UIView) {
        if let frameLabel = frame.viewWithTag(Self.tag) {
            frameLabel.removeFromSuperview()
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        frame.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
            self.topAnchor.constraint(equalTo: frame.bottomAnchor, constant: 10) // 왜 상수가 필요한가...
        ])
    }
    
    static func remove(from frame: UIView) {
        frame.viewWithTag(Self.tag)?.removeFromSuperview()
    }
}
