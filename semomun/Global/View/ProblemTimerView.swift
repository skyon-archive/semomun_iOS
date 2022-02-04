//
//  ProblemTimerView.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/22.
//

import UIKit

final class ProblemTimerView: UIView {
    private let color = UIColor(.mainColor)
    
    private lazy var clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = self.color
        return imageView
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.color
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.contentMode = .left
        return label
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.addSubviews(self.clockImageView, self.timeLabel)
        self.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            self.clockImageView.widthAnchor.constraint(equalToConstant: 20),
            self.clockImageView.heightAnchor.constraint(equalToConstant: 20),
            self.clockImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.clockImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.timeLabel.leadingAnchor.constraint(equalTo: self.clockImageView.trailingAnchor, constant: 5),
            self.timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func configureTime(to time: Int64) {
        self.timeLabel.text = time.toTimeString()
    }
}
