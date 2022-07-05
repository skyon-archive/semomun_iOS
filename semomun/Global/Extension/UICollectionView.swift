//
//  UICollectionView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

extension UICollectionView {
    /// UICollectionView 좌우 여백
    static let gridPadding: CGFloat = 32
    /// UICollectionViewCell 간 여백
    static let gutterWidth: CGFloat = 12
    static var columnCount: Int {
        let deviceWidth = UIScreen.main.bounds.width
        return Int(
            ((deviceWidth - Self.gridPadding * 2) / 168)
                .rounded(.toNearestOrAwayFromZero)
        )
    }
    static var cellWidth: CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        return ((deviceWidth - Self.gridPadding * 2) - (CGFloat(Self.columnCount - 1) * Self.gutterWidth)) / CGFloat(Self.columnCount)
    }
}
