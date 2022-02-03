//
//  SectionDateLabel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import UIKit

class SectionDateLabelFrame: UIView {
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
        
        guard let mainColor = UIColor(named: SemomunColor.mainColor) else { return }
        guard let backgroundColor = UIColor(named: SemomunColor.tableViewBackground) else { return }
        label.textColor = filled ? .white : mainColor
        label.layer.borderColor = mainColor.cgColor
        label.backgroundColor = filled ? mainColor : backgroundColor
    }
}
