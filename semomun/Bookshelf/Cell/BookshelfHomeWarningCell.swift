//
//  BookshelfHomeWarningCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/08.
//

import UIKit

final class BookshelfHomeWarningCell: UICollectionViewCell {
    static let identifier = "BookshelfHomeWarningCell"
    static let cellHeight: CGFloat = UICollectionView.bookcoverCellSize.height
    private var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayout()
    }
    
    private func configureLayout() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.layer.cornerRadius = CGFloat.cornerRadius12
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.borderWidth = 1
        
        self.contentView.addSubview(self.warningLabel)
        NSLayoutConstraint.activate([
            self.warningLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.warningLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
    
    override func prepareForReuse() {
        self.contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func configureTitle(section: Int) {
        self.contentView.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        switch section {
        case 0: self.updateText(to: "최근에 푼 문제집")
        case 1: self.updateText(to: "최근에 구매한 문제집")
        case 2: self.updateText(to: "실전 모의고사")
        default: assertionFailure("불릴 수 없는 곳")
        }
    }
    
    func configureTitle(sectionName: String) {
        self.updateText(to: sectionName)
    }
    
    private func updateText(to sectionName: String) {
        if sectionName.contains("실전 모의고사") {
            self.warningLabel.text = "아직 \(sectionName)가 없어요"
        } else {
            self.warningLabel.text = "아직 \(sectionName)이 없어요"
        }
    }
}
