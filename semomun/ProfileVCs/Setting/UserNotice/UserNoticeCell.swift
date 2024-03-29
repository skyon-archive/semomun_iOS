//
//  UserNoticeCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import UIKit

final class UserNoticeCell: UITableViewCell {
    static let identifier = "UserNoticeCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(.grayTextColor)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func configure(using userNotice: UserNotice) {
        self.titleLabel.text = userNotice.title
        self.dateLabel.text = userNotice.createdDate.yearMonthDayText
    }
}

extension UserNoticeCell {
    private func commonInit() {
        self.accessoryType = .disclosureIndicator
        
        self.contentView.addSubview(titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 28),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 22),
        ])
        
        self.contentView.addSubview(dateLabel)
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.dateLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8)
        ])
    }
}
