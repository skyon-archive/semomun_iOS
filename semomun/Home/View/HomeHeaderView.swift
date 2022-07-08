//
//  HomeHeaderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/08.
//

import UIKit

class HomeHeaderView: UIView {
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(.logo)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 48),
            view.heightAnchor.constraint(equalToConstant: 38.99),
        ])
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.text = "세모문"
        label.textColor = UIColor.getSemomunColor(.blueRegular)
        
        return label
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.text = "반가워요:)\n오늘도 함께 공부해봐요"
        label.numberOfLines = 2
        label.textAlignment = .right
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.addSubviews(self.logoImageView, self.titleLabel, self.greetingLabel)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 66),
            
            self.logoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.logoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.logoImageView.trailingAnchor, constant: 12),
            
            self.greetingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.greetingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
}
