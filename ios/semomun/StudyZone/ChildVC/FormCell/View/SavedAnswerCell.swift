//
//  SavedAnswerCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/24.
//

import UIKit

class SavedAnswerCell: UICollectionViewCell {
    static let identifier = "SavedAnswerCell"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor(.blueRegular)?.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        
        self.contentView.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            self.label.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        self.label.font = .systemFont(ofSize: 12, weight: .medium)
        self.label.textColor = UIColor(.blueRegular) ?? .black
        self.label.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    func configureText(to text: String) {
        self.label.text = text
    }
    
    func makeWrong() {
        self.layer.borderColor = UIColor(.orangeRegular)?.cgColor
        self.label.textColor = UIColor(.orangeRegular) ?? .red
    }
    
    func makeCorrect() {
        self.layer.borderColor = UIColor(.blueRegular)?.cgColor
        self.label.textColor = UIColor(.blueRegular) ?? .black
    }
}
