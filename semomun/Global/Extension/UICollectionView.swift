//
//  UICollectionView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

extension UICollectionView {
    /* public */
    /// UICollectionViewCell 간 여백
    static let gutterWidth: CGFloat = 12
    /// 섹션간 상하 여백
    static let sectionVerticalSpacing: CGFloat = 40
    /// 같은 섹션 내 상하 행의 여백
    static let lineSpacingInSection: CGFloat = 32
    /// UICollectionView 좌우 여백
    static let gridPadding: CGFloat = 32
    static var columnCount: Int {
        let deviceWidth = UIScreen.main.bounds.width
        return Int(
            ((deviceWidth - Self.gridPadding * 2) / 168)
                .rounded(.toNearestOrAwayFromZero)
        )
    }
    static var bookcoverCellSize: CGSize {
        // 62는 문제집 제목과 출판사가 있는 하단 영역의 높이
        return .init(Self.cellWidth, Self.cellWidth / 4 * 5 + 62)
    }
    /* private */
    private static var cellWidth: CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        return ((deviceWidth - Self.gridPadding * 2) - (CGFloat(Self.columnCount - 1) * Self.gutterWidth)) / CGFloat(Self.columnCount)
    }
}

// MARK: Public
extension UICollectionView {
    /// 기본 그리드 시스템에 맞추기 위해서 viewDidLoad에서 호출해야 함. 
    func configureDefaultDesign() {
        self.contentInset = .init(top: Self.gridPadding, left: 0, bottom: Self.gridPadding, right: 0)
        self.backgroundColor = .clear
    }
}
