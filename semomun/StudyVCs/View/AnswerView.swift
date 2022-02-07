//
//  AnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/07.
//

import UIKit

final class AnswerView: UIView {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: SemomunImage.answerImage)
        return imageView
    }()
    private lazy var answerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.addSubview(self.backgroundImageView)
        
        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.backgroundImageView.addSubview(self.answerLabel)
        NSLayoutConstraint.activate([
            self.answerLabel.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor, constant: 13),
            self.answerLabel.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor, constant: 13),
            self.answerLabel.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor, constant: -16),
            self.answerLabel.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor, constant: -6)
        ])
    }
    
    func configureAnswer(to answer: String) {
        self.answerLabel.text = answer
    }
}
