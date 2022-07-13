//
//  SearchWarningCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/13.
//

import UIKit

final class SearchWarningCell: UICollectionViewCell {
    static let identifier = "SearchWarningCell"
    static let cellHeight: CGFloat = UICollectionView.bookcoverCellSize.height
    private var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        label.text = "검색 결과가 없어요"
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
        self.contentView.addSubview(self.warningLabel)
        NSLayoutConstraint.activate([
            self.warningLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.warningLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
}
