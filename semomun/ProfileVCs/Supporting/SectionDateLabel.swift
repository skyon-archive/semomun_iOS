//
//  SectionDateLabel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import UIKit

final class SectionDateLabelFrame: UIView {
    convenience init(text: String, filled: Bool) {
        self.init()
        self.commonInit(text: text, filled: filled)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit(text: String = "", filled: Bool = false) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            label.widthAnchor.constraint(equalToConstant: 113),
            label.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        label.text = text
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 14
        
        guard let deepMint = UIColor(.deepMint) else { return }
        guard let backgroundColor = UIColor(.tableViewBackground) else { return }
        label.textColor = filled ? .white : deepMint
        label.layer.borderColor = deepMint.cgColor
        label.backgroundColor = filled ? deepMint : backgroundColor
    }
}
